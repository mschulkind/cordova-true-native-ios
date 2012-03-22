SConscript('CoffeeScripts/SConscript', variant_dir='build', duplicate=0)

coffeescripts = [
    'environment',

    # Base
    'countdown_callback',
    'date_time_util',
    'listenable',
    'platform',
    'ui_util',
    'util',

    # UI Plugins
    'ui_component_plugin',
    # Views
    'ui_view_plugin',
    'ui_action_sheet_plugin',
    'ui_button_plugin',
    'ui_date_picker_view_plugin',
    'ui_image_view_plugin',
    'ui_label_plugin',
    'ui_map_view_plugin',
    'ui_picker_view_plugin',
    'ui_scroll_view_plugin',
    'ui_spinner_plugin',
    'ui_table_view_plugin',
    'ui_table_view_row_plugin',
    'ui_text_field_plugin',
    # Windows
    'ui_window_plugin',
    'ui_mail_compose_window_plugin',
    'ui_navigation_controller_plugin',
    'ui_tab_controller_plugin',
    'ui_tab_plugin',

    # Other Plugins
    'facebook_plugin',
    'file_plugin',
    'http_plugin',
    'location_autocomplete_plugin',
    'progress_hud_plugin',

    # Controls
    'grid_cell_control',

    # Other
    'title_bar',
    'spinnerize',
]

javascripts = ['Components/underscore.js/underscore.js']
javascripts.append(map((lambda x: "build/%s.js" % x), coffeescripts))
Command('build/all.js', javascripts, "cat $SOURCES > $TARGET")

base64_bld = Builder(
    action = 'echo "static NSString* encoded"`basename $TARGET .h | sed s/Encoded//`" = @\\""`base64 $SOURCE`"\\";" > $TARGET')
env = Environment(BUILDERS = {'Base64' : base64_bld})
env.Base64('Classes/EncodedJavascript.h', 'build/all.js')
env.Base64('Classes/EncodedCitiesUS.h', 'scripts/cities_US.json')
