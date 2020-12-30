//article3 - Action Manager

//Update enums article3_update, draw_hud, and user_event0
enum LWO {
    TXT_HUD,
    TXT_WLD,
    CAM_WLD,
    SPR_HUD,
    SPR_WLD,
    PLR_CTL
}
enum ACT {
    DIALOG, //See draw scripts, depends on sub-objects
    //obj_type, x, y, l, h, bg_spr, bg_spr_speed, text_full, font, alignment, scroll_speedm, scroll_sound], 
    CAMERA, //Sets the camera to a specific point
    //action_time, x, y, focus_type, smooth 
    WINDOW, //Makes a hud window
    //window_num, x, y, [contentoverride]
    CONTROL, //Controls players
    //player_id, life_time, state_override, input_array
    SPRITE,
    
    WAIT, //waits
    //frames
    MUSIC, //set music
    //type, 1, 2
    SET //Set article data
    //article_id, variable, value
}


enum P {
    LOAD,
    ROOM_ID,
    SCENE_ID,
    ACTION_ID,
    ALIVE_TIME,
    ACTION_INDEX,
    DIE
}

enum L {
    ACTION_TYPE,
    PARAM,
    ON_EXIT
}

if !_init {
	with obj_stage_article if num == 5 other.room_manager = id;
	//debug = true;
    reload_scenes();
    error_code = change_scene(1);
    //print_debug("ERROR: "+string(error_code));
    _init = 1;
    exit;
}


if array_length_1d(end_action_queue) > 0 process_end_queue();
if array_length_1d(end_action_index) > 0 process_end_index();
if array_length_1d(action_queue) > 0 process_action_queue();

action_tick();
scene_tick();

#define process_action_queue()
for (var i = 0; i < array_length_1d(action_queue);i++) {
	start_action(action_queue[i][0], action_queue[i][1], action_queue[i][2]);
}
action_queue = []; //clear queue;
return true;
#define process_end_queue()
for (var i = 0; i < array_length_1d(end_action_queue);i++) {
	end_action_id(action_queue[i][0], action_queue[i][1], action_queue[i][2]);
}
end_action_queue = []; //clear queue;
return true;
#define process_end_index()
for (var i = 0; i < array_length_1d(end_action_index); i++) {
	for (var j = 0; j < array_length_1d(cur_actions); j++) {
		if cur_actions[j][P.ACTION_INDEX] == end_action_index[i] 
			end_action(cur_actions[j][P.ACTION_INDEX]);
	}
}
end_action_index = []; //clear queue;
return true;
#define do_action(_action) //Action Per Frame
if _action[P.ROOM_ID] != 0 && _action[P.ROOM_ID] != room_id return false; //Only process actions effecting the current room, or the All Room
var _param = _action[P.LOAD][L.PARAM];
switch _action[P.LOAD][L.ACTION_TYPE] {
    case ACT.DIALOG: 
    	//end action if attack pressed & at end of line
    	if obj_stage_main.follow_player.attack_down && 
    	_action[P.ALIVE_TIME] * _param[10] > string_length(_param[7]) {
    		_action[@P.DIE] = true;
    	}
    	break;
    case ACT.CAMERA: //action_time, x, y, focus_type, smooth 
    	//obj_stage_main.cam_state = 1;
    	switch _param[3] {
    		case 1:
    			cam_pos = [obj_stage_main.follow_player.x+_param[1],obj_stage_main.follow_player.y+_param[2]];
    			cam_smooth = _param[4];
    			break;
    		case 0:
		    	cam_pos = [_param[1],_param[2]];
		    	cam_smooth = _param[4];
		    	break;
    	}
    	if _action[P.ALIVE_TIME] > _param[0] {
    		obj_stage_main.cam_state = 0; //Set the cam back to normal
    		_action[@P.DIE] = true;
    	}
    	break;
    case ACT.CONTROL:
    	with oPlayer {
    		if _param[1] == all || _param[1] == id {
		    	if _param[2] >= 0 && state != _param[2] { 
		    		set_state(_param[2]);
		    	}
    		}
    	}
    	if _action[P.ALIVE_TIME] > _param[0] {
    		_action[@P.DIE] = true;
    	}
    	break;
    case ACT.WAIT: //Does what it says
	    if _action[P.ALIVE_TIME] > _param[0] {
    		_action[@P.DIE] = true;
    	}
    	break;
    default: //type with no code here
    	//print_debug("ACTION UNDEFINED");
        break;
}


if _action[P.DIE] == true {
	end_action(_action[P.ACTION_INDEX]);
	action_ended = true; //Action ended in the do sequence
}

#define change_scene(_scene_id)
if array_length_1d(scene_array[room_id]) < _scene_id return false;
for (var i = 0; i < array_length_1d(cur_actions); i++) end_action(cur_actions[i][P.ACTION_INDEX]);
cur_scene = scene_array[room_id][_scene_id];
scene_id = _scene_id;

for (var i = 0; i < array_length_1d(cur_scene); i++) start_action(room_id, scene_id, cur_scene[i]);

return true;

#define action_tick()
for (var i = 0; i < array_length_1d(cur_actions); i++) {
	cur_actions[@i][@P.ALIVE_TIME]++;
    do_action(cur_actions[i]);
	i -= action_ended;
	action_ended = false;
}
return true;

#define start_action(_room_id, _scene_id, _action_id)
if _action_id > array_length_1d(action_array[_room_id][_scene_id])-1 {
	print_debug("[AM] ACTION "+string(_action_id)+" OUTSIDE INITIALIZED RANGE...");
	return false;
}
if debug print_debug("[AM] ACTION LIVE: "+string(_action_id));
var new_action = array_create(P.DIE+1);
new_action[P.LOAD] = array_clone(action_array[_room_id][_scene_id][_action_id]);
new_action[P.ROOM_ID] = _room_id;
new_action[P.SCENE_ID] = _scene_id;
new_action[P.ACTION_ID] = _action_id;
new_action[P.ACTION_INDEX] = action_index;
action_index++;
new_action[P.ALIVE_TIME] = 0;

//On action start
//print_debug(string(new_action[P.LOAD]));
switch new_action[P.LOAD][L.ACTION_TYPE] {
	case ACT.CAMERA:
			obj_stage_main.cam_state = 1;
			print_debug("[AM] CAM CONTROL SET TO "+string(_action_id));
		break;
	case ACT.WINDOW:
		var _param = new_action[P.LOAD][L.PARAM];
		var win_over = _param[3];
		with obj_stage_main {
			if array_length_1d(win_data) < _param[0] {
				print_debug("[AM] WINDOW OUTSIDE OF INITIALIZED RANGE...");
				return false;
			}
			if win_over != [] { //if override
				//for(var i = 0; i < array_length_1d(win_over); i++) {
					//win_data[@_param[0]][@(i+1)] = win_over[i];
				//}
			}
			array_push(active_win,[[_param[1],_param[2],new_action[P.ACTION_INDEX],0],array_clone(win_data[_param[0]])]); //Push window data to active windows in the right format 
								//[[pos_x,pos_y,action_id,alive_time], [meta]]
		}
		//for (var j = 0; j < array_length_1d(new_action[P.LOAD][L.ON_EXIT]); j++) start_action(room_id, scene_id, new_action[P.LOAD][L.ON_EXIT][j]); //Add Exit Actions
		//return true; //Never enters the queue
		break;
	case ACT.SET:
		var _param = new_action[P.LOAD][L.PARAM];
		with obj_stage_article if "action_article_index" in self && action_article_index == _param[0] {
			variable_instance_set(id,_param[1],_param[2]);
			if other.debug print_debug("[AM] SETTING "+string(_param[0])+"."+string(_param[1])+" = "+string(_param[2]));
		}
		for (var j = 0; j < array_length_1d(new_action[P.LOAD][L.ON_EXIT]); j++) start_action(room_id, scene_id, new_action[P.LOAD][L.ON_EXIT][j]); //Add Exit Actions
		return true; //Never enters the queue
		break;
	case ACT.MUSIC:
		var _param = new_action[P.LOAD][L.PARAM];
    	switch _param[0] {
    		case 0: //play music
    			music_play_file(_param[1]);
    			break;
			case 1: //crossfade
				music_crossfade(false,_param[2]);
				break;
			case 2: //fadeout
				music_fade(_param[1],_param[2]);
				break;
			case 3: //stop
				music_stop();
				break;
    		default:
    			break;
    	}
    	for (var j = 0; j < array_length_1d(new_action[P.LOAD][L.ON_EXIT]); j++) start_action(room_id, scene_id, new_action[P.LOAD][L.ON_EXIT][j]); //Add Exit Actions
		return true; //Never enters the queue
    default:
        break;
}

array_push(cur_actions, new_action);
return true;

#define end_action_id(_room_id, _scene_id, _action_id) //On action End
for (var i = 0; i < array_length_1d(cur_actions); i++) {
	
    if cur_actions[i][P.ACTION_ID] == _action_id {
    	if debug print_debug("[AM] ACTION "+string(cur_actions[i][P.ACTION_INDEX])+":"+string(cur_actions[i][P.ACTION_ID])+" ENDED");
    	for (var j = 0; j < array_length_1d(cur_actions[i][P.LOAD][L.ON_EXIT]); j++) start_action(room_id, scene_id, cur_actions[i][P.LOAD][L.ON_EXIT][j]); //Add Exit Actions
        cur_actions = array_cut(cur_actions, i);
        break;
    }
}
return true;

#define end_action(_action_index) //On action End
for (var i = 0; i < array_length_1d(cur_actions); i++) {
	
    if cur_actions[i][P.ACTION_INDEX] == _action_index {
    	if debug print_debug("[AM] ACTION "+string(cur_actions[i][P.ACTION_INDEX])+":"+string(cur_actions[i][P.ACTION_ID])+" ENDED");
    	for (var j = 0; j < array_length_1d(cur_actions[i][P.LOAD][L.ON_EXIT]); j++) start_action(room_id, scene_id, cur_actions[i][P.LOAD][L.ON_EXIT][j]); //Add Exit Actions
        cur_actions = array_cut(cur_actions, i);
        
        break;
    }
}
return true;

#define scene_tick()
scene_time++;
return true;
#define reload_scenes()

user_event(0); //Run scene load scripts

return true;

#define array_cut(_array, _index)
var _array_cut = array_create(array_length_1d(_array)-1);
var j = 0;
for (var i = 0; i < array_length_1d(_array); i++) {
	if i != _index {
		_array_cut[@j] = _array[i];
		j++;
	}
}
return _array_cut;