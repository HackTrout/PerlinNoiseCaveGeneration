extends Node2D


export(NoiseTexture) var perlin_noise : NoiseTexture
export(int) var grid_width = 40
export(int) var grid_height = 40
export(float) var grid_cell_size = 4.0
export(float, 0.0, 1.0, 0.01) var min_block_value = 0.5

var grid : Array

export(bool) var draw_grid = true
export(Color) var grid_line_color = Color.white
export(Color) var grid_cell_color = Color.black
export(float) var grid_line_width = 3.0
export(bool) var draw_grid_text = true
export(Texture) var grid_label_zero : Texture
export(Texture) var grid_label_one : Texture

#On Generation -----------------------------------------------------------------

func _ready() -> void:
	#Assign Texture to TextureRect for Debugging
	$TextureRect.texture = perlin_noise
	
	#Generate Grid
	perlin_noise.connect("changed", self, "generate_grid")


func generate_grid() -> void:
	#Wipe Grid Array to Prevent Memory Leaks
	if grid.empty() != true:
		for x in range(grid.size()):
			grid[x].clear()
		grid.clear()
	
	#Create 2D Array for Grid
	grid = []
	for x in range(grid_width):
		grid.append([])
		for y in range(grid_height):
			grid[x].append(0)
	
	#Manipulate NoiseTexture Image Data and Generate Grid
	var noise_image = perlin_noise.get_data()
	if noise_image != null:
		noise_image.lock()
		for i in range(grid_width):
			for j in range(grid_height):
				if noise_image.get_width() > i * grid_cell_size && noise_image.get_height() > j * grid_cell_size:
					var value = noise_image.get_pixel(i * grid_cell_size, j * grid_cell_size).r
					if value >= min_block_value:
						grid[i][j] = 1
					else:
						grid[i][j] = 0
				else:
					grid[i][j] = 0
	
	#Draw Grid
	update()


#Runtime ------------------------------------------------------------------------

func _process(delta):
	#Update Grid when Pressing Space
	if Input.is_action_just_pressed("ui_accept"):
		#Generate Grid
		generate_grid()
		update()


func _draw():
	#Draw Grid
	if draw_grid:
		#Draw Grid Cells
		for x in range(grid_width):
			for y in range(grid_height):
				var rect = Rect2(Vector2(x * grid_cell_size, y * grid_cell_size), Vector2.ONE * grid_cell_size)
				if grid[x][y] == 1:
					draw_rect(rect, grid_cell_color)
				
				#Draw Grid Labels
				if draw_grid_text:
					var text_scale = grid_cell_size - (int(grid_cell_size) % 9)
					rect.position += Vector2.ONE * ((grid_cell_size - text_scale) / 2.0)
					rect.size = Vector2.ONE * text_scale
					
					if grid[x][y] == 1:
						draw_texture_rect(grid_label_one, rect, false)
					else:
						draw_texture_rect(grid_label_zero, rect, false)
		
		#Draw Grid Lines
		for x in range(grid_width):
			var p0 = Vector2(x * grid_cell_size, 0)
			var p1 = Vector2(x * grid_cell_size, grid_height * grid_cell_size)
			draw_line(p0, p1, grid_line_color, grid_line_width)
		draw_line(Vector2(grid_width * grid_cell_size, 0), Vector2(grid_width * grid_cell_size, grid_height * grid_cell_size), grid_line_color, grid_line_width)
		
		for y in range(grid_height):
			var p0 = Vector2(0, y * grid_cell_size)
			var p1 = Vector2(grid_width * grid_cell_size, y * grid_cell_size)
			draw_line(p0, p1, grid_line_color, grid_line_width)
		draw_line(Vector2(0, grid_height * grid_cell_size), Vector2(grid_width * grid_cell_size, grid_height * grid_cell_size), grid_line_color, grid_line_width)
		
