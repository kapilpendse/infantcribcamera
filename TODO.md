# Issues

- If you already have role SNSSuccessFeedback stack creation will fail.  This is the default role name when setting up SMS delivery logging, so many people would likey have this already.  I’d recommend something else (like AIDoorLock_SMSRole demo or something), or allowing this to be a user defined value/create if needed.
- In the demo runbook, make enrolled_guest.jpg in red text so it more explicitly is called out.  (I missed this step).


# Ideas

1. SMS should be sent to the host and the expected guest every time the door is successfully.

