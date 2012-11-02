class Rectangle
  def initialize(window, color)
    @window = window
    @color = color

  end

  def mouse_click(mouse_x, mouse_y)
    if mouse_x > OFFSET_MIDDLE - 70 && mouse_x <= OFFSET_MIDDLE || mouse_x > WINDOW_SIZE_X - OFFSET_RIGHT
      return
    end
    if mouse_x > OFFSET_MIDDLE
      cur_pos_x = OFFSET_MIDDLE
    else
      cur_pos_x = OFFSET_LEFT
    end

    width = 41
    while cur_pos_x < mouse_x do
      cur_pos_x = cur_pos_x + width
    end
    cur_pos_x = cur_pos_x - width if mouse_x > OFFSET_LEFT
    if mouse_y >= WINDOW_SIZE_Y / 2 + OFFSET_BOTTOM
      cur_pos_y = WINDOW_SIZE_Y / 2 + OFFSET_BOTTOM
      height = (WINDOW_SIZE_Y) / 2 - OFFSET_BOTTOM - OFFSET_TOP
    else
      cur_pos_y = OFFSET_TOP

      height = (WINDOW_SIZE_Y - OFFSET_BOTTOM - OFFSET_TOP) / 2
    end
    draw_rec(cur_pos_x, cur_pos_y, width, height)
  end

  def draw_rec(cur_pos_x, cur_pos_y, width, height)
    @window.draw_line(cur_pos_x, cur_pos_y, @color, cur_pos_x, cur_pos_y + height, @color, 0)
    @window.draw_line(cur_pos_x + width, cur_pos_y, @color, cur_pos_x + width, cur_pos_y + height, @color, 0)
    @window.draw_line(cur_pos_x, cur_pos_y, @color, cur_pos_x + width, cur_pos_y, @color, 0)
    @window.draw_line(cur_pos_x, cur_pos_y + height, @color, cur_pos_x + width, cur_pos_y + height, @color, 0)

  end
end