#!/bin/bash

function set_vars() {

  # Link to where the CSS resides.
  css_link="https://raw.githubusercontent.com/gio-salvador/slack_dark_theme/master/dark_theme.css"
  # Path to the file to be edited.
  slack_edit="/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js"

  # Lines to be added to the file.
  lines="
    document.addEventListener('DOMContentLoaded', function() {
      let tt__customCss = \`.menu ul li a:not(.inline_menu_link) {color: #fff !important;}\`
      \$.ajax({
          url: \"$css_link\",
          success: function(css) {
              \$('<style></style>').appendTo('head').html(css + tt__customCss);
              \$('<style></style>').appendTo('head').html('#reply_container.upload_in_threads .inline_message_input_container {background: padding-box #545454}');
              \$('<style></style>').appendTo('head').html('.p-channel_sidebar {background: #363636 !important}');
              \$('<style></style>').appendTo('head').html('#client_body:not(.onboarding):not(.feature_global_nav_layout):before {background: inherit;}');
          }
      });
    });
  }"
  #echo $lines
}

function rollback_setup(){
  SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
  # Display how to roll back
  echo -e """#!/bin/bash

slack_edit='/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js'
sudo cp \$slack_edit.$DATE \$slack_edit
unset slack_edit""" > $SCRIPTPATH/turn_slack_back.sh
  echo -e "INFO: To reverse settings, just run: \n bash $SCRIPTPATH/turn_slack_back.sh"
}

function edit_slack_file(){
  # Make backup of file to be edited.
  DATE=`date +%Y-%m-%d_%H.%M.%S`
  sudo cp $slack_edit $slack_edit.$DATE

  # Make the changes for dark mode if not present, by checking if the link to the
  # CSS file is present.
  if ! grep -q "$css_link" "$slack_edit"
  then
    sed -i '' -e '$ d' "$slack_edit"
    echo "$lines" | sudo tee -a "$slack_edit" > /dev/null
    osascript -e 'tell application "Slack" to quit'
    sleep 3
    open -a "Slack"
    rollback_setup
  else
    echo -e "WARNING: Changes failed to apply because they're already present!"
    exit 1
  fi
}

function clean_up(){
  unset css_link slack_edit lines gnubin gnuman DATE
}

function main(){
  # Exit at any time if Error
  set -e

  # Set necessary vars
  # Future note, if necessary make them arguments
  set_vars

  # Function to actually modify the file.
  edit_slack_file

  # Function to clean up variables if script is run with 'source'
  clean_up
}

main
