TN.UI.MailComposeWindow = class MailComposeWindow extends TN.UI.Window
  PLUGIN_NAME: 'mailcomposewindow'

  @canSendMail = (successHandler, errorHandler) ->
    localSuccessHandler = (canSendMail) ->
      if canSendMail
        successHandler()
      else
        errorHandler()
        alert(
          "Unable to send mail. Please add a mail account to your device.")

    Cordova.exec(localSuccessHandler, null, @pluginID, 'canSendMail', [])

  constructor: (options) ->
    super

    @subject = options?.subject
    @messageBody = options?.messageBody

