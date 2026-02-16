# frozen_string_literal: true

require "test_helper"

class TalksControllerTest < ActionDispatch::IntegrationTest
  # Index

  test "GET index renders talks" do
    get talks_path

    assert_response :success
    assert_select "li", minimum: 1
  end

  test "GET index does not create a session" do
    get talks_path

    assert_response :success
    assert_nil session[:session_id]
  end

  test "GET index renders subsequent pages with page parameter" do
    get talks_path(page: 2)

    assert_response :success
  end

  # Show

  test "GET show renders a talk" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    get talk_path(talk)

    assert_response :success
    assert_select "h1", text: talk.title
  end

  test "GET show returns not found for unknown slug" do
    get talk_path(id: "nonexistent-zzz999")

    assert_response :not_found
  end

  test "GET show does not create a session" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    get talk_path(talk)

    assert_response :success
    assert_nil session[:session_id]
  end

  test "GET show redirects legacy numeric IDs" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    get talk_path(id: talk.id)

    assert_response :moved_permanently
    assert_redirected_to talk_path(talk)
  end

  # New

  test "GET new requires authentication" do
    get new_talk_path

    assert_response :unauthorized
  end

  test "GET new renders form when authenticated" do
    login

    get new_talk_path

    assert_response :success
    assert_select "form"
  end

  # Create

  test "POST create requires authentication" do
    post talks_path, params: { talk: { title: "Test", event: "TestConf", held_at: Time.current } }

    assert_response :unauthorized
  end

  test "POST create creates a talk and redirects" do
    login

    assert_difference "Talk.count", 1 do
      post talks_path, params: { talk: { title: "New Talk", event: "RubyConf", held_at: 1.day.ago, description: "A talk" } }
    end

    talk = Talk.last
    assert_redirected_to talk_path(talk)
  end

  test "POST create renders form on validation error" do
    login

    assert_no_difference "Talk.count" do
      post talks_path, params: { talk: { title: "", event: "", held_at: "" } }
    end

    assert_response :unprocessable_entity
  end

  # Edit

  test "GET edit requires authentication" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    get edit_talk_path(talk)

    assert_response :unauthorized
  end

  test "GET edit renders form when authenticated" do
    login
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    get edit_talk_path(talk)

    assert_response :success
    assert_select "form"
  end

  # Update

  test "PATCH update requires authentication" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    patch talk_path(talk), params: { talk: { title: "Updated" } }

    assert_response :unauthorized
  end

  test "PATCH update updates the talk and redirects" do
    login
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    patch talk_path(talk), params: { talk: { title: "Updated Title" } }

    assert_redirected_to talk_path(talk)
    assert_equal "Updated Title", talk.reload.title
  end

  test "PATCH update renders form on validation error" do
    login
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    patch talk_path(talk), params: { talk: { title: "" } }

    assert_response :unprocessable_entity
  end

  # Destroy

  test "DELETE destroy requires authentication" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    delete talk_path(talk)

    assert_response :unauthorized
  end

  test "DELETE destroy deletes the talk and redirects" do
    login
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    assert_difference "Talk.count", -1 do
      delete talk_path(talk)
    end

    assert_redirected_to talks_path
  end

  private
    def login
      post login_path, params: { login: { username: "alice", password: "hunter2" } }
    end
end
