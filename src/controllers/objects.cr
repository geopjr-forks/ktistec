require "../framework/controller"

class ObjectsController
  include Balloon::Controller

  skip_auth ["/objects/:id"], GET

  get "/objects/:id" do |env|
    iri = "#{host}/objects/#{env.params.url["id"]}"

    unless (object = get_object(env, iri))
      not_found
    end

    env.response.content_type = "application/activity+json"
    render "src/views/objects/object.json.ecr"
  end

  get "/remote/objects/:id" do |env|
    id = env.params.url["id"].to_i64

    unless (object = get_object(env, id))
      not_found
    end

    env.response.content_type = "application/activity+json"
    render "src/views/objects/object.json.ecr"
  end

  private def self.get_object(env, iri_or_id)
    if (object = ActivityPub::Object.find?(iri_or_id))
      if object.visible
        object
      elsif (iri = env.current_account?.try(&.iri))
        if object.to.try(&.includes?(iri)) || object.cc.try(&.includes?(iri))
          object
        end
      end
    end
  end
end
