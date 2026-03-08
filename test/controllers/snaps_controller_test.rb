# frozen_string_literal: true

require "test_helper"

class SnapsControllerTest < ActionDispatch::IntegrationTest
  # Index

  test "GET index renders snaps page" do
    get snaps_path

    assert_response :success
  end

  test "GET index does not create a session" do
    get snaps_path

    assert_response :success
    assert_nil session[:session_id]
  end

  test "GET gallery show renders gallery page" do
    gallery = galleries(:hiking_gallery)

    get gallery_path(gallery)

    assert_response :success
  end

  # Show

  test "GET show renders a snap" do
    snap = snaps(:sky_1)

    get snap_path(snap)

    assert_response :success
  end

  test "GET show does not create a session" do
    snap = snaps(:sky_1)

    get snap_path(snap)

    assert_response :success
    assert_nil session[:session_id]
  end

  test "GET show returns not found for unknown slug" do
    get snap_path(id: "nonexistent-zzz999")

    assert_response :not_found
  end

  # New

  test "GET new requires authentication" do
    get new_snap_path

    assert_response :unauthorized
  end

  test "GET new renders form when authenticated" do
    login

    get new_snap_path

    assert_response :success
    assert_select "form"
  end

  # Create

  test "POST create requires authentication" do
    post snaps_path, params: { snap: { title: "Test" } }

    assert_response :unauthorized
  end

  test "POST create creates a snap and redirects" do
    login

    assert_difference "Snap.count", 1 do
      post snaps_path, params: {
        snap: {
          title: "New Snap",
          caption: "A test snap",
          file: fixture_file_upload("photo.jpg", "image/jpeg")
        }
      }
    end

    assert_redirected_to snaps_path
  end

  test "POST create with gallery_title groups into gallery" do
    login

    assert_difference "Snap.count", 1 do
      post snaps_path, params: {
        snap: {
          title: "New Hiking Snap",
          gallery_title: "Hiking",
          file: fixture_file_upload("photo.jpg", "image/jpeg")
        }
      }
    end

    snap = Snap.last
    assert_equal "Hiking", snap.gallery.title
  end

  test "POST create renders form on validation error" do
    login

    assert_no_difference "Snap.count" do
      post snaps_path, params: { snap: { title: "" } }
    end

    assert_response :unprocessable_entity
  end

  # Edit

  test "GET edit requires authentication" do
    snap = snaps(:sky_1)

    get edit_snap_path(snap)

    assert_response :unauthorized
  end

  test "GET edit renders form when authenticated" do
    login
    snap = snaps(:sky_1)

    get edit_snap_path(snap)

    assert_response :success
    assert_select "form"
  end

  # Update

  test "PATCH update requires authentication" do
    snap = snaps(:sky_1)

    patch snap_path(snap), params: { snap: { title: "Updated" } }

    assert_response :unauthorized
  end

  test "PATCH update updates the snap and redirects" do
    login
    snap = snaps(:sky_1)

    patch snap_path(snap), params: { snap: { title: "Updated Title" } }

    assert_redirected_to snaps_path
    assert_equal "Updated Title", snap.reload.title
  end

  test "PATCH update renders form on validation error" do
    login
    snap = snaps(:sky_1)

    patch snap_path(snap), params: { snap: { title: "" } }

    assert_response :unprocessable_entity
  end

  # Destroy

  test "DELETE destroy requires authentication" do
    snap = snaps(:sky_1)

    delete snap_path(snap)

    assert_response :unauthorized
  end

  test "DELETE destroy deletes the snap and redirects" do
    login
    snap = snaps(:sky_1)

    assert_difference "Snap.count", -1 do
      delete snap_path(snap)
    end

    assert_redirected_to snaps_path
  end

  private
    def login
      post login_path, params: { login: { username: "alice", password: "hunter2" } }
    end
end
