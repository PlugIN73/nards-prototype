gem 'gosu'
require "gosu"
require 'net/telnet'
require "./Rectangle.rb"
WINDOW_SIZE_X = 640
WINDOW_SIZE_Y = 593
OFFSET_TOP = 10
OFFSET_MIDDLE = WINDOW_SIZE_X / 2 + 25
OFFSET_BOTTOM = 25
OFFSET_LEFT = 35
OFFSET_RIGHT = 50
require "./Nard.rb"

class GameWindow < Gosu::Window
  def initialize
    super WINDOW_SIZE_X + 50, WINDOW_SIZE_Y + 100, false
    self.caption = "Nards"
    @roll = Gosu::Image.new(self, "images/roll_active.png", true, 0, 0, 200, 60)
    @background_image = Gosu::Image.new(self, "images/bg.jpg", true, 0, 0, 640, 593)
    @nard_side_1 = Nard.new(self, 1)
    @nard_side_2 = Nard.new(self, 2)
    @rect = Rectangle.new(self,Gosu::Color::RED);
    @cursor = Gosu::Image.new(self, "images/cursor.png", true, 0, 0, 35, 35)
    @mouse_down = false
    @count_movement = []

    @client = Net::Telnet.new('Host'=>'localhost', 'Port'=>7000, "Prompt"=>/^\+OK/n)
    @client.cmd("get_side"){ |str| @side = str.to_i}
    @movement = @side == 1 ? true : false
    p @side
    p @movement

  end

  def update
      if mouseup?
        mouse_x = mouse_x()
        mouse_y = mouse_y()
        count_side_1 = @nard_side_1.get_count_nards_on_position(get_position_x(mouse_x), get_position_y(mouse_y))
        count_side_2 = @nard_side_2.get_count_nards_on_position(get_position_x(mouse_x), get_position_y(mouse_y))
        if mouse_x > OFFSET_MIDDLE - 70 && mouse_x <= OFFSET_MIDDLE || mouse_x > WINDOW_SIZE_X - OFFSET_RIGHT
          return
        end
        unless !@movement
          if @side == 1
            if !@nard_side_1.selected_nard? && count_side_1 > 0
              @nard_side_1.select_nard(get_position_x(mouse_x), get_position_y(mouse_y))
            end
            if @nard_side_1.selected_nard? && count_side_2 == 0 && @nard_side_1.can_move_to_position(get_position_x(mouse_x), get_position_y(mouse_y), @count_movement)
              if @nard_side_1.move_selected_to_position(get_position_x(mouse_x), get_position_y(mouse_y))
                @client.cmd("move_selected_to_position #{@side} #{get_position_x(mouse_x)} #{get_position_y(mouse_y)} #{@nard_side_1.selected_index}")
                @nard_side_1.selected_index = -1

                if @count_movement.empty?
                  sleep(0.1)
                  @client.cmd("your_movement #{@side}")
                  @movement = false
                end
              end
            end
          else
            if !@nard_side_2.selected_nard? && count_side_2 > 0
              @nard_side_2.select_nard(get_position_x(mouse_x), get_position_y(mouse_y))
            end
            if @nard_side_2.selected_nard? && count_side_1 == 0 && @nard_side_2.can_move_to_position(get_position_x(mouse_x), get_position_y(mouse_y), @count_movement)
              if @nard_side_2.move_selected_to_position(get_position_x(mouse_x), get_position_y(mouse_y))
                @client.cmd("move_selected_to_position #{@side} #{get_position_x(mouse_x)} #{get_position_y(mouse_y)} #{@nard_side_2.selected_index}")
                @nard_side_2.selected_index = -1
                p @count_movement
                if @count_movement.empty?
                  sleep(0.1)
                  @client.cmd("your_movement #{@side}")
                  @movement = false
                end
              end
            end
          end
        end
      else
        if button_down?(Gosu::MsLeft)
          @mouse_down = true
        end
      end
      if button_down?(Gosu::MsLeft) && 230 < mouse_x() && mouse_x() < 460  && 620 < mouse_y() && mouse_y() < 680
        roll
      end
  end

  def mouseup?
    if !button_down?(Gosu::MsLeft) && @mouse_down == true
      @mouse_down = false
      return true
    end
    return false
  end

  def draw
    cmd, *arg = @client.cmd("get_message #{@side}").chomp.split
    if cmd == "move_selected_to_position"
      if @side == 1
        @nard_side_2.move_selected_to_position(arg[0].to_i, arg[1].to_i, arg[2].to_i)
      else
        @nard_side_1.move_selected_to_position(arg[0].to_i, arg[1].to_i, arg[2].to_i)
      end
    end
    if cmd == "your_movement"
      @movement = true
    end
    @background_image.draw(0, 0, 0)
    @nard_side_1.draw
    @nard_side_2.draw
    @cursor.draw(mouse_x(), mouse_y(), 9999)
    @roll.draw(230, 620, 0) if @movement
    if @bone_first && @bone_second
      @bone_first.draw(50, 620, 0)
      @bone_second.draw(120, 620, 0)
    end
  end

  def get_position_x(mouse_x)
    if mouse_x > OFFSET_MIDDLE - 70 && mouse_x <= OFFSET_MIDDLE || mouse_x > WINDOW_SIZE_X - OFFSET_RIGHT
      return 0
    end
    if mouse_x > OFFSET_MIDDLE
      i = 6
      x = OFFSET_MIDDLE
    else
      i = 0
      x = OFFSET_LEFT
    end
    while mouse_x > x
      mouse_x = mouse_x - 41
      i = i + 1
    end
    return i
  end

  def get_position_y(mouse_y)
    if mouse_y >= WINDOW_SIZE_Y / 2 + OFFSET_BOTTOM
      return 2
    else
      return 1
    end
  end

  def roll
    first = rand(6) + 1
    second = rand(6) + 1
    @bone_first = Gosu::Image.new(self, "images/" + first.to_s + ".png", true, 0, 0, 60, 60)
    @bone_second = Gosu::Image.new(self, "images/" + second.to_s + ".png", true, 0, 0, 60, 60)
    @count_movement.clear
    @count_movement = [first, second]
  end
end

window = GameWindow.new
window.show