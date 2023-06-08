require "application_system_test_case"

class MinutesTest < ApplicationSystemTestCase
  setup do
    @minute = minutes(:one)
  end

  test "visiting the index" do
    visit minutes_url
    assert_selector "h1", text: "Minutes"
  end

  test "should create minute" do
    visit minutes_url
    click_on "New minute"

    fill_in "Agreements", with: @minute.agreements
    fill_in "Discussed topics", with: @minute.discussed_topics
    fill_in "End time", with: @minute.end_time
    fill_in "Meeting date", with: @minute.meeting_date
    fill_in "Meeting notes", with: @minute.meeting_notes
    fill_in "Meeting objectives", with: @minute.meeting_objectives
    fill_in "Meeting title", with: @minute.meeting_title
    fill_in "Pending topics", with: @minute.pending_topics
    fill_in "Start time", with: @minute.start_time
    click_on "Create Minute"

    assert_text "Minute was successfully created"
    click_on "Back"
  end

  test "should update Minute" do
    visit minute_url(@minute)
    click_on "Edit this minute", match: :first

    fill_in "Agreements", with: @minute.agreements
    fill_in "Discussed topics", with: @minute.discussed_topics
    fill_in "End time", with: @minute.end_time
    fill_in "Meeting date", with: @minute.meeting_date
    fill_in "Meeting notes", with: @minute.meeting_notes
    fill_in "Meeting objectives", with: @minute.meeting_objectives
    fill_in "Meeting title", with: @minute.meeting_title
    fill_in "Pending topics", with: @minute.pending_topics
    fill_in "Start time", with: @minute.start_time
    click_on "Update Minute"

    assert_text "Minute was successfully updated"
    click_on "Back"
  end

  test "should destroy Minute" do
    visit minute_url(@minute)
    click_on "Destroy this minute", match: :first

    assert_text "Minute was successfully destroyed"
  end
end
