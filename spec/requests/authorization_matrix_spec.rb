require "rails_helper"

# Drift guard for authorization. Every routed controller#action is classified
# in MATRIX; the first example pins MATRIX to the live route set, the rest
# probe each bucket over real HTTP. Adding, removing or regating an action
# fails the pin or a sweep until the row agrees.
RSpec.describe "Authorization matrix", type: :request do
  # Vocabulary:
  #   :no_login  — reachable without a session
  #   :public    — any signed-in user
  #   Roles::X   — allowed role set; every other signed-in user is denied
  #   :record    — per-record visibility; probes in #record_probes
  MATRIX = {
    "sessions#new" => :no_login,
    "sessions#create" => :no_login,
    "sessions#destroy" => :no_login,
    "passwords#new" => :no_login,
    "passwords#create" => :no_login,
    "passwords#edit" => :no_login,
    "passwords#update" => :no_login,
    "home#index" => :public
    # "diary_entries#index" => Roles::STAFF,
    # "diary_entries#show"  => :record,
  }.freeze

  # Weakest role first. Used to pick the least-privileged allowed role per rule.
  ROLE_ORDER = %i[customer_custodian customer instructor admin].freeze

  ENGINE_NAMESPACES = %r{\A(active_storage|action_mailbox|action_text|rails|turbo)/}
  ABSENT = 0

  let(:world) do
    @world ||= {
      customer_custodian: create_user(role: :customer_custodian),
      customer: create_user(role: :customer),
      instructor: create_user(role: :instructor),
      admin: create_user(role: :admin)
    }
  end

  def user_for(role) = world.fetch(role)

  def route_for(pair)
    controller, action = pair.split("#")
    Rails.application.routes.routes.reject(&:internal).find do |r|
      r.defaults[:controller] == controller && r.defaults[:action] == action
    end
  end

  def request_for(pair, ids = {})
    route = route_for(pair)
    verb = route.verb.split("|").first.downcase
    path = route.format(route.required_parts.index_with { |part| ids.fetch(part, ABSENT) })
    [ verb, path ]
  end

  def probe(pair, ids: {}, params: {})
    verb, path = request_for(pair, ids)
    public_send(verb, path, params: params)
  end

  def denied?
    response.redirect? && response.location == root_url && flash[:alert].present?
  end

  def allowed?
    response.status < 400 && !denied?
  end

  # Ids for :record and gated GETs that need a real record. Default ABSENT.
  def probe_ids(_pair) = {}

  # Params for POST/PATCH probes that would raise before the gate without them.
  def probe_params(_pair) = {}

  it "classifies exactly the routed controller#action set" do
    routes = Rails.application.routes.routes.reject(&:internal)
    strays = routes.filter_map { |r| r.defaults[:controller] }.uniq
                   .select { |c| c.include?("/") }.grep_v(ENGINE_NAMESPACES)
    expect(strays).to eq([]), "namespaced controllers escape the matrix: #{strays.sort.join(', ')}"

    routed = routes.filter_map do |r|
      c, a = r.defaults.values_at(:controller, :action)
      "#{c}##{a}" if c && a && !c.include?("/")
    end.uniq

    expect(routed - MATRIX.keys).to eq([]), "routed but not in MATRIX"
    expect(MATRIX.keys - routed).to eq([]), "in MATRIX but not routed"
  end

  it "redirects every non-:no_login action to login without a session" do
    offenders = MATRIX.filter_map do |pair, rule|
      next if rule == :no_login

      probe(pair, ids: probe_ids(pair), params: probe_params(pair))
      "#{pair}: got #{response.status}" unless response.redirect? && response.location == new_session_url
    end
    expect(offenders).to eq([])
  end

  it "denies the weakest role every role-gated action" do
    sign_in(user_for(ROLE_ORDER.first))
    offenders = MATRIX.filter_map do |pair, rule|
      next unless rule.is_a?(Array) && !rule.include?(ROLE_ORDER.first)

      probe(pair, params: probe_params(pair))
      "#{pair}: expected deny, got #{response.status}" unless denied?
    end
    expect(offenders).to eq([])
  end

  it "lets the weakest role reach every :public action" do
    sign_in(user_for(ROLE_ORDER.first))
    offenders = MATRIX.filter_map do |pair, rule|
      next unless rule == :public

      probe(pair, ids: probe_ids(pair), params: probe_params(pair))
      "#{pair}: got #{response.status}" unless allowed?
    end
    expect(offenders).to eq([])
  end

  it "lets the weakest allowed role reach each gated GET action" do
    gated = MATRIX.select { |_, rule| rule.is_a?(Array) }
    offenders = []

    gated.group_by { |_, roles| ROLE_ORDER.find { |role| roles.include?(role) } }
         .sort_by { |role, _| ROLE_ORDER.index(role) }
         .each do |role, entries|
      sign_in(user_for(role))
      entries.map(&:first).sort.each do |pair|
        verb, = request_for(pair, probe_ids(pair))
        next unless verb == "get"

        probe(pair, ids: probe_ids(pair), params: probe_params(pair))
        offenders << "#{pair}: expected #{role} through, got #{response.status}" unless allowed?
      end
    end

    expect(offenders).to eq([])
  end

  # [who, pair, ids, params, expectation] — one row per boundary worth pinning.
  def record_probes
    [
      # [:instructor, "diary_entries#show", { id: world[:own_entry].id }, {}, :allowed],
      # [:instructor, "diary_entries#show", { id: world[:foreign_entry].id }, {}, :not_found]
    ]
  end

  it "scopes :record actions to visible records" do
    offenders = []
    signed_in_as = nil

    record_probes.each do |who, pair, ids, params, expectation|
      unless signed_in_as == who
        sign_in(world[who])
        signed_in_as = who
      end
      probe(pair, ids: ids, params: params)

      met = case expectation
      when :allowed then allowed?
      when :denied then denied?
      when :not_found then response.status == 404
      end
      offenders << "#{pair} (#{who}): expected #{expectation}, got #{response.status}" unless met
    end

    expect(offenders).to eq([])
  end
end
