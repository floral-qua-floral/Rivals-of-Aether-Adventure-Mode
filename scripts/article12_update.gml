//article12_update, lights

if _init == 0 {
    spr_name = "article1_"+string(spawn_variables[0]);
    spr_ = sprite_get(spr_name);
    if spawn_variables[3] != 0 sprite_change_collision_mask(spr_name,true, 2, 0, 0, sprite_get_width(spr_), sprite_get_height(spr_), 0 );
    if spawn_variables[0] < 1000 render_sprite = sprite_get("article1_"+string(spawn_variables[0]));
    else render_sprite = spawn_variables[0];
    //mask_index = sprite_index;
    anim_speed = spawn_variables[1]*.01;
    group = spawn_variables[2];
    static  = spawn_variables[4];
    alpha_ = spawn_variables[5];
    with obj_stage_article if num == 5 other.room_manager = id;
    if alpha_ != 0 image_alpha = alpha_;
    //if static image_alpha = 0;
    _init = 1;
} else {
	/*if static {
		//with room_manager {
			x = room_manager.static_position[0];
			y = room_manager.static_position[1];
		//}
	}*/
    /*with room_manager {
        other.x = view_get_xview()+init_pos[0]*16;
		other.y = view_get_yview()+init_pos[1]*16;
        //other.init_cam_pos = init_cam_pos;
    }*/
    //visible = false;
    //print_debug(string(marker[current_marker]));
    /*if wait_time > 0 {
        wait_time--;
        hsp = 0;
        vsp = 0;
    }
    if wait_time == 0 && marker[current_marker] != 0 move_to(current_marker,spe);*/
    
    //frame_update();
    
    //if static print_debug(string([x,y]));
   /* x = init_x;
    y = init_y;*/
    image_index = (image_index + anim_speed) % image_number;

}

draw = true;