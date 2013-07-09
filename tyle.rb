# Tyle Map Editor

VERSION = "0.7"
DEBUG = true

# This is used to make the filename of the saved/loaded map data.
# There will be FILENAME_space,_world,and _props.tyle saved using
# this constant as the base.
FILENAME = "debugland"

require 'rubygems' # This is only needed on older Rubies, I think, but it does no harm.
require 'gosu'

# This makes it easier to spit debugging output to the console.
# I know I should probably raise exceptions and rescue them, but
# this is easier.  Sue me.  Lifted it from jCaster by Jahmaican.
def debug(message)
  puts "#{Time.now.strftime("%H:%M:%S.%L")} - \t#{message}" if DEBUG
end

# Theese are clever and Spooner is a clever man.
# Also handsome I presume.
def image(name)
  File.expand_path("tex/#{name}", File.dirname(__FILE__))
end

def data(name)
  File.expand_path("#{name}", File.dirname(__FILE__))
end

debug("Tyle v" + VERSION + "\n\t\tby Allcaps")

class Gamewindow < Gosu::Window
	def initialize
		debug("Starting up.")
		super 1024, 768, false
		@map = Map.new(self)
		@player = Player.new(self)
		self.caption = "Tyle v#{VERSION}"
		
		# Start the editor with zoom off.
		@zoom = false
		@camera_x = @camera_y = 0
	end
	
	# Hate programs that hide the cursor.
	def needs_cursor?
		true
	end
	
	# I'm aware that a lot of these could be one-line'd.
	# I'll probably do that once I'm done.
	def button_down(id)
		
		# Exit on escape
		if id == Gosu::KbEscape
			close
		end
		
		# Cursor Movement
		# NSEW = 0123
		if id == Gosu::KbUp
			@player.move(0)
		end
		if id == Gosu::KbDown
			@player.move(1)
		end
		if id == Gosu::KbRight
			@player.move(2)
		end
		if id == Gosu::KbLeft
			@player.move(3)
		end
		
		# Camera Movement
		# These should probably be farther from the load/save keys heh
		if id == Gosu::KbI
			if @zoom
				@camera_y -= 16 * 4
			else
				@camera_y -= 16
			end
		end
		if id == Gosu::KbK
			if @zoom
				@camera_y += 16 * 4
			else
				@camera_y += 16
			end
		end
		if id == Gosu::KbJ
			if @zoom
				@camera_x -= 16 * 4
			else
				@camera_x -=  16
			end
		end
		if id == Gosu::KbL
			if @zoom
				@camera_x += 16 * 4
			else
				@camera_x += 16
			end
		end
		if id == Gosu::KbM # Toggle lame, janky zoom
			@zoom = !@zoom

			# If we're turning zoom on, set the camera so it zooms
			# to the area the cursor is at, if we're turning zoom off
			# then just reset the camera to show the full editor field.
			if @zoom
				@camera_x = @player.x
				@camera_y = @player.y
			else
				@camera_x = 0
				@camera_y = 0
			end
		end
		
		
		# Editor Functions
		if id == Gosu::KbQ # Scroll left through sprites
			@player.change(1)
		end
		if id == Gosu::KbW # Scroll right through sprites
			@player.change(2)
		end
		if id == Gosu::KbA # Place a tile as a world tile
			@player.place(1)
		end
		if id == Gosu::KbS # Place a tile as a prop, draw above world tiles
			@player.place(2)
		end
		if id == Gosu::KbD # Clear a tiles world/prop/collision info, setting it to nil
			@player.place(3)
		end
		if id == Gosu::KbZ # Mark a tile for collision, only drawn in the editor
			@player.place(4)
		end
		if id == Gosu::KbX # Turn on/off drawing of the red cross-circle that shows where colliders are
			@map.draw_colliders?
		end
		
		# Save / Load Functions (Still Experimental, but working)
		# Make sure that the file you're trying to load was made
		# by the same version of Tyle you're using now, else oddness.
		if id == Gosu::KbO and DEBUG
			@map.save(FILENAME)
		end
		if id == Gosu::KbP and DEBUG
			@map.load(FILENAME)
		end
		
	end
	
	def update
		# No game logic in the editor, really.  I'm sure there's something
		# I'm doing that should be here instead of in the rendering code or
		# attached to a button, but eh.
	end
	
	def draw
		# The translate call uses the inverse of the camera values so when you
		# scroll the map it feels like you're moving the camera insted of moving
		# the whole map.  This also seems like an ugly way to toggle zoom.
		translate(-@camera_x, -@camera_y) do
			if @zoom
				scale(4,4,@camera_x, @camera_y) do
					@map.draw
					@player.draw
				end
			else
				@map.draw
				@player.draw
			end
		end
	end
end

# Player is actually the cursor.  I was trying to make the game, and midway decided I needed
# to make the editor first, so this still uses the old name.  Oh well.  Maybe I'll change it
# once I'm more or less done and I pretty everything up.  Maybe not.
class Player
	
	attr_reader :x
	attr_reader :y
	
	def initialize(window)
		@window = window
		@cursor = Gosu::Image.new(window, image("cursor.png"), false)
		@art = Gosu::Image.load_tiles(window, image("tiles.png"),16,16,true)
		@selected_sprite = 19 # Start the cursor off at a street sign, because why not.
		@sprite = @art[@selected_sprite]
		@x = @y = 0
	end
	
	def draw
		@sprite.draw(@x,@y,4)
		@cursor.draw(@x,@y,4)
	end
	
	def place(type)
		# This converts the cursor's position
		# into a location in the map arrays.
		# Seems kind of ugly, but it works.
		unless @x == 0
			x = @x / 16
		else
			x = 0
		end
		unless @y == 0
			y = @y / 16
		else
			y = 0
		end
		
		# Map = 1 Prop = 2
		case type
			when 1 # Map Edit
				$test_world[y][x] = @selected_sprite
			when 2 # Prop Edit
				$test_props[y][x] = @selected_sprite
			when 3 # Clear tile
				$test_props[y][x] = nil
				$test_world[y][x] = nil
				$test_space[y][x] = nil
			when 4 # Place collider
				$test_space[y][x] = 1
		end
	end
	
	def change(direction)
		# Back = 1 Forward = 2
		# Scroll through the tiles in the cursor.
		case direction
		when 1
			unless @selected_sprite == 0
				@selected_sprite -= 1
				@sprite = @art[@selected_sprite]
			end
		when 2
			unless @selected_sprite == @art.length - 1
				@selected_sprite += 1
				@sprite = @art[@selected_sprite]
			end
		end
	end
	
	def move(direction)
		# NSEW = 0123
		case direction
		when 0 # North
			unless @y - 16 < 0
				@y -= 16
			end
		when 1 # South
			unless @y + 17 > 768
				@y += 16
			end
		when 2 # East
			unless @x + 17 > 1024
				@x += 16
			end
		when 3 # West
			unless @x - 16 < 0
				@x -= 16
			end
		end
	end
	
end

class Map
	def initialize(window)
		@tiles = Gosu::Image.load_tiles(window,image("tiles.png"),16,16,true)
		@collider = Gosu::Image.new(window,image("col.png"),false)
		# Start off showing colliders, since the maps starts with none
		# starting with them hidden would be confusing when you placed one
		# and nothing showed up on the screen.  Can be toggled with X.
		@draw_colliders = true
	end
	
	def save(filename)
		debug("Saving #{FILENAME}.tyle...")
		File.open(data("#{FILENAME}_world.tyle"),"wb") do |file|
			Marshal.dump($test_world,file)
		end
		File.open(data("#{FILENAME}_props.tyle"),"wb") do |file|
			Marshal.dump($test_props,file)
		end
		File.open(data("#{FILENAME}_space.tyle"),"wb") do |file|
			Marshal.dump($test_space,file)
		end
		debug("Done.")
	end
	
	def load(filename)
		debug("Loading #{FILENAME}.tyle...")
		File.open(data("#{FILENAME}_world.tyle"),"rb") do |file|
			$test_world = Marshal.load(file)
		end
		File.open(data("#{FILENAME}_props.tyle"),"rb") do |file|

			$test_props = Marshal.load(file)
		end
		File.open(data("#{FILENAME}_space.tyle"),"rb")do |file|
			$test_space = Marshal.load(file)
		end
		debug("Done.")
	end
	
	def draw_colliders?
		# Toggle if we should render colliders or not.
		@draw_colliders = !@draw_colliders
	end
	
	def draw
		x = 0
		y = 0
		$test_world.each do |e|
			e.each do |i|
				if i == nil
					@tiles[0].draw(x,y,1)
				else
					@tiles[i].draw(x,y,1)
				end
				x += 16
			end
			x = 0
			y += 16
		end
		self.draw_props
	end
	
	def draw_props
		x = 0
		y = 0
		$test_props.each do |e|
			e.each do |i|
				unless i == 0 or i == nil
					@tiles[i].draw(x,y,2)
				end
				x += 16
			end
			x = 0
			y += 16
		end
		# Only continue the draw chain if colliders are to be drawn.
		if @draw_colliders
			self.draw_colliders
		end
	end
	
	def draw_colliders
		x = 0
		y = 0
		$test_space.each do |e|
			e.each do |i|
				unless i == 0 or i == nil
					@collider.draw(x,y,3)
				end
				x += 16
			end
			x = 0
			y += 16
		end
	end
end

# The editor spawns a blank 1024x768 map when it's opened, though it
# can really do any size I guess.  Eventually you'll be able to set your
# own size.  I'm also going to add map truncation, so that unused space is
# removed from your map when you do the final save of it, which will reduce
# file size and make rendering it less messy.  For now though, enjoy these
# nil-filled arrays.

$test_space = Array.new(48) {Array.new(64) {nil}}

$test_props = Array.new(48) {Array.new(64) {nil}}

$test_world = Array.new(48) {Array.new(64) {nil}}

# Lets start this bad Jackson.
Gamewindow.new.show
