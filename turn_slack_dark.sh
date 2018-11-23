#!/bin/bash

css_link="https://raw.githubusercontent.com/gio-salvador/slack_dark_theme/master/dark_theme.css"
slack_edit="/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js"

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

# Check gnu-sed is installed
if [ "$(which gsed | wc -l)" == "0" ]
then
  brew install gsed
fi

# Check PATHS are correct
gnubin='export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"'
if ! grep -Fxq "$gnubin" ~/.bash_profile
then
  echo "$gnubin" >> ~/.bash_profile
  source ~/.bash_profile
fi

gnuman='export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"'
if ! grep -Fxq "$gnuman" ~/.bash_profile
then
  echo "$gnuman" >> ~/.bash_profile
  source ~/.bash_profile
fi

# Make backup copy
DATE=`date +%Y-%m-%d`
sudo cp $slack_edit $slack_edit.$DATE

# Display how to roll back
echo -e """
In case you need to roll back, just run:

slack_edit='/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js'
sudo cp $slack_edit.$DATE $slack_edit
unset slack_edit
"""

# Make the changes for dark mode if not present
if ! grep -q "$css_link" "$slack_edit"
then
  sudo gsed -i '$ d' "$slack_edit"
  echo "$lines" | sudo tee -a "$slack_edit" > /dev/null
else
  echo -e "ERROR: Changes failed because they're already present!"
  exit 1
fi

unset lines slack_edit gnuman gnubin DATE
