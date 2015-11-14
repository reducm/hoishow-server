require "bmp_reader"

def draw_image(map_url)
  return "缺少图片" if !map_url
  image = BMP::Reader.new(map_url)
  w = image.width
  h = image.height

  color_hash = {}
  coordinate_array = []
  result_hash = {}

  (h-1).downto(0) do |y|
    0.upto(w-1) do |x|
      color = image[x, y]
      if color != "ffffff"
        temp = color_hash[color] || []
        temp.push([x,y])
        color_hash[color] = temp
      end
    end
  end

  #sort coordinate to path
  color_hash.keys.each do |color|
    #根据颜色取出所有坐标
    coordinate_array = color_hash[color]
    #随机选择一个坐标作为当前坐标
    current_coordinate = coordinate_array[0]
    sorted_array = []
    sorted_array.push(current_coordinate)
    sort_coordinate(coordinate_array, sorted_array, current_coordinate)
    #组成排序后的hash,优化方案：每5个坐标取一个
    sorted_array = sorted_array.select { |c| sorted_array.index(c) % 5 == 0 }
    result_hash[color] = sorted_array.flatten.join(",")
  end

  result_hash["width"] = image.width
  result_hash["height"] = image.height
  result_hash
end

def sort_coordinate(coordinate_array, sorted_array, current_coordinate)
  return "参数错误" if ( coordinate_array.empty? or current_coordinate.nil? )

  #找出当前坐标的第一个相邻坐标
  neighbor_coordinate = nil
  (1..9).each do |range|
    neighbor_coordinate = coordinate_array.select{ |x| (x[0] - current_coordinate[0]).abs == range && (x[1] - current_coordinate[1]).abs < range+1}.first
    if neighbor_coordinate.nil?
      neighbor_coordinate = coordinate_array.select{ |x| (x[1] - current_coordinate[1]).abs == range  && (x[0] - current_coordinate[0]).abs < range}.first
    else
      break
    end
    break if neighbor_coordinate != nil
  end

  #将当前坐标放进目标数组
  sorted_array.push(neighbor_coordinate) if neighbor_coordinate != nil
  #从所有坐标数组中删除当前坐标
  coordinate_array.delete_at(coordinate_array.index(current_coordinate))
  #将相邻坐标当成当前坐标后循环操作
  current_coordinate = neighbor_coordinate
  sort_coordinate(coordinate_array, sorted_array,current_coordinate)
end
