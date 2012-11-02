
class Nard
  attr_accessor :selected_index
  def initialize(window, side)
    @selected_index = -1
    if side == 1
      @nard = Gosu::Image.new(window, "images/white-nard3.png", true, 0, 0, 35, 35)
      position_x = 1
      position_y = 2
    else
      @nard = Gosu::Image.new(window, "images/black-nard.png", true, 0, 0, 35, 35)
      position_x = 12
      position_y = 1
    end
    @nard_x_array = {}
    @nard_y_array = {}
    @nard_lap_array = {}
    @nard_side_array = {}
    @nard_position_x_array = {}
    @nard_position_y_array = {}
    15.times { |i|
      @nard_x_array[i] = get_x_position(position_x)
      @nard_y_array[i] = get_y_position(position_x, position_y)
      @nard_lap_array[i] = 0
      @nard_side_array[i] = 1
      @nard_position_x_array[i] =  position_x
      @nard_position_y_array[i] = position_y
    }
  end

  def draw
    15.times{ |i|
      @nard.draw(@nard_x_array[i], @nard_y_array[i], @nard_y_array[i])
    }
  end

  def get_x_position(position)
    if position > 6
      x = OFFSET_LEFT + 25
      (position).times{x = x + 41}
    else
      x = OFFSET_LEFT + 3
      (position - 1).times{x = x + 41}
    end
    return x
  end

  def get_y_position(position_x, position_y)
    if position_y == 1
      y = OFFSET_TOP
      get_count_nards_on_position(position_x, position_y).times{y = y + 15}
    else
      y = WINDOW_SIZE_Y - OFFSET_BOTTOM * 3
      get_count_nards_on_position(position_x, position_y).times{y = y - 15}
    end
    return y
  end

  def get_count_nards_on_position(position_x, position_y)
    count = 0
    @nard_y_array.size.times { |i|
      count = count + 1 if @nard_position_x_array[i] == position_x && @nard_position_y_array[i] == position_y
    }
    return count
  end

  def select_nard (position_x, position_y)
    @selected_index = -1
    if position_y == 1
      y = 0
    else
      y = 999
    end
    15.times{
      |i|
      if @nard_position_y_array[i] == position_y && @nard_position_x_array[i] == position_x
        if position_y == 2
          if y > @nard_y_array[i]
            @selected_index = i
            y = @nard_y_array[i]
          end
        else
          if y < @nard_y_array[i]
            @selected_index = i
            y = @nard_y_array[i]
          end
        end
      end
    }
  end

  def selected_nard?
    @selected_index != -1
  end

  def move_selected_to_position(position_x, position_y, index = false)
    unless index
      if @nard_position_x_array[@selected_index] == position_x && @nard_position_y_array[@selected_index] == position_y
        return false
      else
        @nard_x_array[@selected_index] = get_x_position(position_x)
        @nard_y_array[@selected_index] = get_y_position(position_x, position_y)
        @nard_position_x_array[@selected_index] = position_x
        @nard_position_y_array[@selected_index] = position_y
        if position_y == 1
          recalculate_coords(position_x, position_y)
        end
        return true
      end
    else
      @nard_x_array[index] = get_x_position(position_x)
      @nard_y_array[index] = get_y_position(position_x, position_y)
      @nard_position_x_array[index] = position_x
      @nard_position_y_array[index] = position_y
      if position_y == 1
        recalculate_coords(position_x, position_y)
      end
      true
    end
  end

  def recalculate_coords(position_x, position_y)
    y = OFFSET_TOP
    15.times{
      |i|
      if @nard_position_x_array[i] == position_x && @nard_position_y_array == position_y
        @nard_y_array[i] = y
        y = y + 15
      end
    }
  end

  def can_move_to_position(position_x, position_y, count_movement)
    if @nard_position_y_array[@selected_index] == 1
      count_movement.each{ |value|
        if position_y == 1
          if @nard_position_x_array[@selected_index] - value == position_x
            return true
          end
        else
          if @nard_position_x_array[@selected_index] - 1 == value - position_x
            return true
          end
        end
      }
    else
      count_movement.each{ |value|
        if position_y == 2
          if @nard_position_x_array[@selected_index] + value == position_x
            count_movement.delete value
            return true
          end
        else
          temp = 12 - @nard_position_x_array[@selected_index]
          if 12 - value + temp + 1 == position_x
            count_movement.delete value
            return true
          end
        end
      }
    end
    return false
  end
end