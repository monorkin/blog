# frozen_string_literal: true

require "application_system_test_case"

class JapaneseInputTest < ApplicationSystemTestCase
  test "kana mode converts romaji into kana with ruby annotations" do
    login
    visit new_article_url

    editor_content.click
    enable_kana_mode
    type("konnnichiha")

    within editor do
      assert_selector "ruby rt", text: "ko"
      assert_selector "ruby rt", text: "ni"
      assert_selector "ruby rt", text: "chi"
      assert_selector "ruby rt", text: "ha"
    end
    assert_includes editor_text_without_readings, "こんにちは"
  end

  test "uppercase romaji converts into katakana" do
    login
    visit new_article_url

    editor_content.click
    enable_kana_mode
    type("KO-HI-")

    within editor do
      assert_selector "ruby rt", text: "kō"
      assert_selector "ruby rt", text: "hī"
    end
    assert_includes editor_text_without_readings, "コーヒー"
  end

  test "romaji is not converted while kana mode is off" do
    login
    visit new_article_url

    editor_content.click
    type("kore ha pen desu")

    within editor do
      assert_text "kore ha pen desu"
      assert_no_selector "ruby"
    end
  end

  test "annotated kana round-trips through saving and editing" do
    login
    visit new_article_url

    fill_in "Title", with: "Japanese practice"
    editor_content.click
    enable_kana_mode
    type("sushi")
    click_button "Save draft"

    assert_selector ".lexxy-content ruby rt", text: "su"

    article = Article.find_by!(title: "Japanese practice")
    assert_match %r{<ruby>す<rt>su</rt></ruby>}, article.body.to_s
    assert_match %r{<ruby>し<rt>shi</rt></ruby>}, article.body.to_s

    visit edit_article_url(slug: article.to_param)

    within editor do
      assert_selector "ruby rt", text: "su"
      assert_selector "ruby rt", text: "shi"
    end
  end

  private
    def login
      visit login_path

      fill_in "Username", with: users(:alice).username
      fill_in "Password", with: "hunter2"
      click_button "Login"

      assert_text "Logout"
    end

    # Batched send_keys drops keystrokes in the headless Lexical editor, so
    # type like a human: one character at a time.
    def type(text)
      text.each_char { |character| editor_content.send_keys(character) }
    end

    def enable_kana_mode
      button = find("button[name='kana']", visible: :all)
      execute_script("arguments[0].click()", button)
      assert_equal "true", button["aria-pressed"], "Kana mode should be enabled"
    end

    def editor
      find("lexxy-editor[connected]")
    end

    def editor_content
      editor.find("[contenteditable='true']")
    end

    def editor_value
      page.evaluate_script("document.querySelector('lexxy-editor').value")
    end

    def editor_text_without_readings
      editor_value.gsub(%r{<rt>[^<]*</rt>}, "").gsub(%r{</?[^>]+>}, "")
    end
end
