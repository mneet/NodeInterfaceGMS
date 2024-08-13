// An Node is the basic interface element, it has the dafult variables for control and visual display

function __num_node() constructor
{
	// System variables
	node_id = -1;
	node_name = ""; 
	node_depth = 0;
	
	transform = {};
	with (transform){
		
		// POSITION
		x = 0;
		y = 0;
		
		// Desired final position
		x_final = 0;
		y_final = 0;
	
		// Initial position that the node will be created
		x_initial = 0;
		y_initial = 0;
		
		fixed_position = false; // If true, the system will ignore the container distribution
		
		// SCALE
		xscale = 1;
		yscale = 1;
		
		xscale_final = 1;
		yscale_final = 1;
		
		xscale_final = 1;
		yscale_final = 1;
		
		// ALPHA||TRANSPARENCY
		alpha = 1;
		alpha_final = 1;
		alpha_initial = 1;
		
		// ROTATION
		rotation = 0;
		rotation_final = 0;
		rotation_initial = 0;	
		
		// SIZE
		width = 0;
		height = 0;
		
		width_final = 0;
		height_final = 0;
		width_initial = 0;	
		height_initial = 0;
	}

}