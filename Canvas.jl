### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 0be1266a-01bc-11eb-3a24-57c28ea50d21
begin
	import Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 129e0e82-01bc-11eb-2142-91b9da370423
begin
	Pkg.add(["Images", "ImageIO", "ImageMagick"])
	using Images
end

# ╔═╡ 3e8c8538-01bb-11eb-07d6-b573a23076b4
function logistic(r, iterations)
	x = 0.5
	
	for i in (1 : iterations)
		x = r*x*(1-x)
	end
	
	
	x
end

# ╔═╡ a572eb02-01bb-11eb-0cf8-793120c966db
logistic(2.8, 1115)

# ╔═╡ 1a83e856-01bc-11eb-202d-b7ad74a44439
image_test = Array{RGB{Normed{UInt8,8}}}(undef, 640,800)

# ╔═╡ 8084842a-01bd-11eb-37ea-1bc7c8619d6c
size(image_test)

# ╔═╡ 42e7aa84-021c-11eb-0e13-8ff9f3e877d0
typeof(image_test)

# ╔═╡ d22357f2-023f-11eb-310a-479e376fbc6a
mutable struct canvas
	image::Array{RGB{Normed{UInt8,8}},2}#(undef, rows, cols)
	
	xL::Float64 # left
	xR::Float64 # right
	
	yT::Float64 # top
	yB::Float64 # bottom
end

# ╔═╡ 98c6512a-0240-11eb-2aed-1fc6a05d81ee
function row_col(cnvs::canvas, xy)
	y_span = cnvs.yT - cnvs.yB
	rows = size(cnvs.image)[1]
	
	rows_per_unit = rows / y_span
	
	y_frac = (cnvs.yT - xy[2]) / y_span
	
	row = convert(Int64, round(y_frac * rows))
	
	
	x_span = cnvs.xR - cnvs.xL
	cols = size(cnvs.image)[2]
	
	cols_per_unit = cols / x_span
	
	x_frac = (xy[1] - cnvs.xL) / x_span
	
	col = convert(Int64, round(x_frac * cols))
	
	
	row, col
end

# ╔═╡ 98c6cf74-0240-11eb-2509-3bea79d2ea09
function row_num(cnvs::canvas, y)
	y_span = cnvs.yT - cnvs.yB
	rows = size(cnvs.image)[1]
	
	rows_per_unit = rows / y_span
	
	y_frac = (cnvs.yT - y) / y_span
	
	
	convert(Int64, round(y_frac * rows)) 
end

# ╔═╡ 98c7ee86-0240-11eb-35c1-b9ce695cbf6d
function col_num(cnvs::canvas, x)
 	x_span = cnvs.xR - cnvs.xL
	cols = size(cnvs.image)[2]
	
	cols_per_unit = cols / x_span
	
	x_frac = (x - cnvs.xL) / x_span
	
	
	convert(Int64, round(x_frac * cols))	 
end

# ╔═╡ 98da2d30-0240-11eb-0714-a91e371ca643
function x_coord(cnvs::canvas, col)
		
	x_span = cnvs.xR - cnvs.xL
	cols = size(cnvs.image)[2] 
	 
	col_frac = col / cols
	
	x_frac = col_frac * x_span
	
	
	cnvs.xL + x_frac		 
end

# ╔═╡ 98db51b0-0240-11eb-1461-dfcfb92c8f98
function y_coord(cnvs::canvas, row)
		
	y_span = cnvs.yT - cnvs.yB
	rows = size(cnvs.image)[1]
	
	row_frac = row / rows
	
	y_frac = row_frac * y_span
	
	cnvs.yT - y_frac
end

# ╔═╡ 98e8c714-0240-11eb-0d74-3db6108f5c67
function wipe!(cnvs::canvas, color)
	
	rows, cols = size(cnvs.image)
	
	for row in (1 : rows)
		for col in (1 : cols)
			cnvs.image[row, col] = color
		end
	end
end

# ╔═╡ 98f4514c-0240-11eb-06be-cf362c1eda07
function x_from_line(xy1, xy2, y)
	
	if xy2[1] - xy1[1] !== 0
		slope = (xy2[2] - xy1[2]) /
	            (xy2[1] - xy1[1])
	
	
		#x_intercept = xy2[1] - xy2[2] / slope
		y_intercept = xy1[2] - xy1[1] * slope

		return (y - y_intercept) / slope
	else
		return xy1[1]
	end
	 
end

# ╔═╡ 99008070-0240-11eb-2546-8ff9576a91af
function y_from_line(xy1, xy2, x)
	
	if xy2[1] - xy1[1] !== 0
		slope = (xy2[2] - xy1[2]) /
				(xy2[1] - xy1[1])

		y_intercept = xy1[2] - xy1[1] * slope

		return slope*x + y_intercept
	else
	
	end
end

# ╔═╡ 9916ef54-0240-11eb-055f-6b838608965d
function scales_equal(cnvs::canvas)
	y_span = cnvs.yT - cnvs.yB
	rows = size(cnvs.image)[1]
	
	rows_per_unit = rows / y_span
	 
	
	x_span = cnvs.xR - cnvs.xL
	cols = size(cnvs.image)[2]
	
	cols_per_unit = cols / x_span 
	 
	
	abs(log(rows_per_unit / cols_per_unit)) < 0.005
end

# ╔═╡ 6240dfb8-021c-11eb-03db-6b6cac1b1dbf
canvas_test = canvas(image_test, -32.0, 32.0, 40.0, -40.0)

# ╔═╡ 87ffc958-021c-11eb-1466-2756cf6715ba
canvas_test.xL = -40.0

# ╔═╡ 5c21e598-021f-11eb-142c-3bfed37e5754
canvas_test.xR = 40.0

# ╔═╡ 6c2fed86-021f-11eb-30e3-d581fd4051ed
canvas_test.yT = 32.0

# ╔═╡ 75392e1a-021f-11eb-201b-e1aa14193fca
canvas_test.yB = -32.0

# ╔═╡ 8ef77db6-021f-11eb-3c21-2717dbbe3382
row_col(canvas_test, (16, 8))

# ╔═╡ 2c97a36a-0244-11eb-3b32-15fc16b99972
wipe!(canvas_test, RGB(0.9, 0.9, 0.9))

# ╔═╡ 3a9f873c-0244-11eb-1e85-57040f4ecd4c
canvas_test

# ╔═╡ 472f07be-0220-11eb-37c8-25f333681f1d
function pixel_to_rgb(cnvs::canvas, xy, rgb)
	row, col = row_col(cnvs, xy) 
	
	cnvs.image[row, col] = RGB(rgb[1], rgb[2], rgb[3])
end

# ╔═╡ b335c488-0221-11eb-3650-91434383480d
function pixel_to_color(cnvs::canvas, xy, clr)
	row, col = row_col(cnvs, xy) 
	
	cnvs.image[row, col] = clr
end

# ╔═╡ 990ce784-0240-11eb-1c97-4ddfbe1675fe
function line(cnvs::canvas, xy1, xy2, color)
	row1, col1 = row_col(cnvs, (xy1))
	row2, col2 = row_col(cnvs, (xy2))
	
	if abs(col2-col1) > abs(row2-row1)
		if col2 > col1
			col_hi = col2
			col_lo = col1
		else
			col_hi = col1
			col_lo = col2
		end
		
		for col in (col_lo : col_hi)
			x = x_coord(cnvs, col)
			y = y_from_line(xy1, xy2, x)
			row = row_num(cnvs::canvas, y)
			pixel_to_color(cnvs, (x, y), color)
		end
		
	else
		if row2 > row1
			row_hi = row2
			row_lo = row1
		else
			row_hi = row1
			row_lo = row2
		end
		
		for row in (row_lo : row_hi)
			y = y_coord(cnvs, row)
			x = x_from_line(xy1, xy2, y)
			col = col_num(cnvs::canvas, x)
			pixel_to_color(cnvs, (x, y), color)
		end		
		
	end
	
end

# ╔═╡ 83f1fa76-0220-11eb-0a75-1f0362124665
pixel_to_rgb(canvas_test, (16, 8), (0.0, 1.0, 0.0))

# ╔═╡ 6d04223e-0221-11eb-1727-75b3a8fe69eb
canvas_test.image

# ╔═╡ c480ea60-0221-11eb-084c-fd3d82f61a94
pixel_to_color(canvas_test, (36, 24), RGB(1,0,0))

# ╔═╡ 13466198-0222-11eb-3ed0-9bef98705ce0
pixel_to_color(canvas_test, (39, 31), RGB(1,1,1))

# ╔═╡ 2512c45c-0222-11eb-3fd8-91fe1249f0ef
canvas_test.image

# ╔═╡ Cell order:
# ╠═0be1266a-01bc-11eb-3a24-57c28ea50d21
# ╠═129e0e82-01bc-11eb-2142-91b9da370423
# ╠═3e8c8538-01bb-11eb-07d6-b573a23076b4
# ╠═a572eb02-01bb-11eb-0cf8-793120c966db
# ╠═1a83e856-01bc-11eb-202d-b7ad74a44439
# ╠═8084842a-01bd-11eb-37ea-1bc7c8619d6c
# ╠═42e7aa84-021c-11eb-0e13-8ff9f3e877d0
# ╠═d22357f2-023f-11eb-310a-479e376fbc6a
# ╠═98c6512a-0240-11eb-2aed-1fc6a05d81ee
# ╠═98c6cf74-0240-11eb-2509-3bea79d2ea09
# ╠═98c7ee86-0240-11eb-35c1-b9ce695cbf6d
# ╠═98da2d30-0240-11eb-0714-a91e371ca643
# ╠═98db51b0-0240-11eb-1461-dfcfb92c8f98
# ╠═98e8c714-0240-11eb-0d74-3db6108f5c67
# ╠═98f4514c-0240-11eb-06be-cf362c1eda07
# ╠═99008070-0240-11eb-2546-8ff9576a91af
# ╠═990ce784-0240-11eb-1c97-4ddfbe1675fe
# ╠═9916ef54-0240-11eb-055f-6b838608965d
# ╠═6240dfb8-021c-11eb-03db-6b6cac1b1dbf
# ╠═87ffc958-021c-11eb-1466-2756cf6715ba
# ╠═5c21e598-021f-11eb-142c-3bfed37e5754
# ╠═6c2fed86-021f-11eb-30e3-d581fd4051ed
# ╠═75392e1a-021f-11eb-201b-e1aa14193fca
# ╠═8ef77db6-021f-11eb-3c21-2717dbbe3382
# ╠═2c97a36a-0244-11eb-3b32-15fc16b99972
# ╠═3a9f873c-0244-11eb-1e85-57040f4ecd4c
# ╠═472f07be-0220-11eb-37c8-25f333681f1d
# ╠═b335c488-0221-11eb-3650-91434383480d
# ╠═83f1fa76-0220-11eb-0a75-1f0362124665
# ╠═6d04223e-0221-11eb-1727-75b3a8fe69eb
# ╠═c480ea60-0221-11eb-084c-fd3d82f61a94
# ╠═13466198-0222-11eb-3ed0-9bef98705ce0
# ╠═2512c45c-0222-11eb-3fd8-91fe1249f0ef
