Feature: Chat UI

@javascript
Scenario: Sending a message
Given I am on chat_page
And I fill in "input-text" with "Hello World!" 
When I press "Send"
Then the chat room's "chat-text" field should contain "Hello World!"

