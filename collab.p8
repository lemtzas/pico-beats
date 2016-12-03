pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

--collab16 cart n, date
--1 cart 16 devs so little space!

cartdata"pico8collab162"
function _draw() if cgame._draw then cgame:_draw() end end
function _update() if cgame._update then cgame:_update() end end

games = {}

menu = {
  _draw = function(self)
    cls()
    sspr(0,0,32,32,32,32,64,64)
    local x = self.sel%4-1
    local y = flr(self.sel/4)
    local rx = 64+(x-1)*16-1
    local ry = 64+(y-2)*16-1
    color"1"
    rect(rx,ry,rx+17,ry+17)
    color"7"
    rect(rx-1,ry-1,rx+18,ry+18)
    local cur = games[self.sel+1]

    color"8"
    cursor(33,24)
    print"pico8-collab16-2"
    color"7"
    cursor(32,97)
    print("game: "..cur.name.."\nauthor: "..cur.author)
  end,
  _update = function(self)
    self.sel = self.sel or 0
    if btnp"0" then self.sel -= 1 sfx"0" end
    if btnp"1" then self.sel += 1 sfx"0" end
    if btnp"2" then self.sel -= 4 sfx"0" end
    if btnp"3" then self.sel += 4 sfx"0" end
    self.sel %= 16
    if btnp"5" or btnp"4" then
      sfx"1"
      cgame = games[self.sel+1]
      if cgame._init then cgame:_init() end
    end
  end,
}
cgame = menu

cameralib = {
  new = function(init)
    init = init or {}
    local self = {}
    self.z = init.z or -3
    self.focallength = init.focallength or 5
    self.fov = init.fov or 45
    self.theta = init.theta or 0
    self.width = init.width or 128
    self.height = init.height or 128

    self.line = cameralib.line
    self.point = cameralib.point

    self._perspective = cameralib._perspective
    self._tan = cameralib._tan
    self._coordstopx = cameralib._coordstopx
    self._map = cameralib._map
    return self
  end,
  line = function(self, p1, p2)
    local px_1 = self:_coordstopx(self:_perspective(p1))
    local px_2 = self:_coordstopx(self:_perspective(p2))
    line(px_1[1], px_1[2], px_2[1], px_2[2])
  end,
  point = function(self, p)
    local px = self:_coordstopx(self:_perspective(p))
    pset(px[1],px[2])
  end,
  _perspective = function(self, p)
    local x,y,z = p[1],p[2],p[3]
    local x_rot = x * cos(self.theta) - z * sin(self.theta)
    local z_rot = x * sin(self.theta) + z * cos(self.theta)
    local dz = z_rot - self.z
    local out_z = self.z + self.focallength
    local m_xz = x_rot / dz
    local m_yz = y / dz
    local out_x = m_xz * out_z
    local out_y = m_yz * out_z
    return { out_x, out_y }
  end,
  _map = function(v, a, b, c, d)
    local partial = (v - a) / (b - a)
    return partial * (d - c) + c
  end,
  _tan = function(v)
    return sin(v) / cos(v)
  end,
  _coordstopx = function(self,coords)
    local x = coords[1]
    local y = coords[2]
    local radius = self.focallength * self._tan(self.fov / 2 / 360)
    local pixel_x = self._map(x, -radius, radius, 0, self.width)
    local pixel_y = self._map(y, -radius, radius, 0, self.height)
    return { pixel_x, pixel_y }
  end
}
git,git_count = "1b6bf2e","52"
function zspr(n,w,h,dx,dy,dz)
  sx = 8 * (n % 16)
  sy = 8 * flr(n / 16)
  sw = 8 * w
  sh = 8 * h
  dw = sw * dz
  dh = sh * dz
  sspr(sx,sy,sw,sh, dx,dy,dw,dh)
end

add(games, {
 name = "midnight drive",
 author = "adrian09_01",
 _init = function(self)
	playercar = {}
	cars = {}
	nextdrive = 0
	score = 0
	over = 2
	local p = {}
 p.x = 48
 p.s = 0
 add(playercar, p)
 return p
 end,
 _update = function(self)
	if over == 0 then
	for car in all (playercar) do
 if (btn(0)) car.x -= 1.5
 if (btn(1)) car.x += 1.5
 if (btn(5)) then
 car.s += 1
 else
 car.s -= 1
 end
 if (car.s > 20) sfx(0)
 if (btn(4)) car.s -= 4
 if (btn(4)) sfx(3)
 if (car.s > 200) car.s = 200
 if (car.s < 0) car.s = 0
 if (car.x < 0) car.x = 0
 if (car.x > 96) car.x = 96
 nextdrive += car.s
 score += car.s/100
end
	for car in all (cars) do
 for pcar in all (playercar) do
 car.y -= car.s - pcar.s/50
 if (car.y >= 110) then
 del(cars, car)
 sfx(2)
 end
 if (car.x < pcar.x + 32 and car.x + 32 > pcar.x and car.y >= 108) over = 1
 end
 end
	if nextdrive > 200 then
 nextdrive = 0
 if (flr(rnd(10)) == 0) self.spawn_car()
 end
	end
 end,
 _draw = function(self)
 map(0,0,0,0,16,16)
 for car in all(cars) do
 zspr(6, 2, 1, car.x, max(car.y, 87), max(-9+car.y/10,0.2))
 end
 for car in all (playercar) do
 zspr(4, 2, 1, car.x, 108, 2)
 print(flr(score).."0m", 16, 8, 8)
 print(car.s.."km/h", 56, 8, 8)
 zspr(36, 1, 1, 108, 80, nextdrive / 75)
 zspr(36, 1, 1, 4, 80, nextdrive / 75)
 end
 if over == 2 then
 print("midnight drive", 32, 32)
 print(" Â— to start", 32, 48)
 if (btnp(4)) over = 0
 end
 end,
 spawn_car = function()
 local p = {}
 p.x = flr(rnd(96))
 p.y = 64
 p.s = flr(rnd(3)+1)
 add(cars, p)
 return p
 end
}
)
xturn = true
add(games,{
	name = "tictactoe",
	author = "@ramilego4game",
	_init = function()
	 camera(-15,-15)
		rectfill(-15,-15,142,142,6)
		sspr(96,96,24,24,0,0,96,96)
		xo = {}
		for x=1,3 do xo[x] = {0,0,0} end
		cx, cy = 1,1
		win = 0
		steps = 0

		function chkxo(x1,y1,x2,y2,x3,y3)
			return xo[x1][y1] == xo[x2][y2] and xo[x2][y2] == xo[x3][y3] and xo[x1][y1] ~= 0
		end

		function calcwin()
		 for x=1,3 do
		  if chkxo(x,1,x,2,x,3)then
		   return xo[x][1]
		  end
		 end
		 for y=1,3 do
		  if chkxo(1,y,2,y,3,y) then
		   return xo[1][y]
		  end
		 end
		 if chkxo(1,1,2,2,3,3) then
		 	return xo[1][1]
		 elseif chkxo(3,1,2,2,1,3) then
		  return xo[2][2]
		 end
		 return steps == 9 and 3 or 0
		end
	end,

	_draw = function()
		if win > 0 then return end
		pal(9,xturn and 12 or 8)
		sspr(120,104,8,8,(cx-1)*32,(cy-1)*32,32,32)
		pal()
		for x=1,3 do for y=1,3 do
		 shp = xo[x][y]
		 if shp > 0 then
		 	sspr(shp==1 and 96 or 104,120,8,8,(x-1)*32,(y-1)*32,32,32)
		 end
		end end
	end,

	_update = function(self)
		if btnp() > 0 and win > 0 then self._init() return end
		sspr(120,96,8,8,(cx-1)*32,(cy-1)*32,32,32)
		if btnp(0) then
			cx -= 1
		elseif btnp(1) then
		 cx += 1
		elseif btnp(2) then
			cy -= 1
		elseif btnp(3) then
		 cy += 1
		end
		cx = mid(1,cx,3)
		cy = mid(1,cy,3)
		if btnp(4) or btnp(5) then
			if xo[cx][cy]<1 then sfx(5)
				xo[cx][cy] = xturn and 1 or 2
				xturn = not xturn
				steps += 1
				self._draw()
				win = calcwin()
				if win > 0 then
					rectfill(15,44,84,55,6)
					if win == 3 then
						color(9)
						print("draw !!!",38,48)
						spr(239,17,46)
					else
					 color(win==1 and 12 or 8)
					 print("player wins !",33,48)
					 spr(253+win,17,46)
					end
					rect(14,43,85,56)
				end
			end
		end
	end
})
add(games,{
		name="super forum poster 2 turbo dx edition",
		author="@fweez",
		_update = function()
			cls()
			map(16,0,0,0,16,16)
			color"6"
			cursor(0,1)
			if not state then
				print"super forum poster 2 turbo dx"
				if (btnp"4") state = 0
			else
				print("@"..player.name.." score:"..score.." time:"..timer)
			end
			if state == 0 then
				if (btn"0") player.x -= 1.5
				if (btn"1") player.x += 1.5
				if (btn"2") player.y -= 1.5
				if (btn"3") player.y += 1.5

				timer -= 1
				if (timer == 0) state = 1
			end

			local yoff = 33
			for a in all(actors) do
				if state == 0 then
					a.x = mid(8, a.x+a.vx, 122)
					if (a.x <= 8 or a.x >= 122) a.vx *= -1
					a.y = mid(42, a.y + (a.vy or 0), 116)
				end
				local s = 64
				if a.color then
					s = 65
					if (a.y >= 116 or a.y <= 42) a.vy *= -1
					if a.y <= 42 then
						del(actors, a)
						add(actors, a)
					elseif a.vy > 0 then
						for o in all(actors) do
							if not o.color and abs(o.y-a.y-7) < 2 and abs(o.x-a.x) <= 6 then
								a.name = o.name
								a.vy = -1
								break
							end
						end
					end
					print("thread:"..a.topic.." lp: @"..a.name, 4, yoff, a.color)
					if (a.name == player.name and state == 0) score += 1
					pal(8, a.color)
					yoff -= 6
				elseif a == player then
					pal(13,14)
				end
				spr(s, a.x-4, a.y)
				pal()
			end

			cursor(4, 44)
			if (state == 1) print"game over"
			if not state then
				print"dominate the forum! z to start"
				print" arrows move. bounce threads,"
				print"and dominate the conversation!"
			end
		end,
		_init = function(self)
			actors = {}
			local function rndchar(l)
				local a = flr(rnd(#l))+1
				return sub(l, a, a)
			end
			local function rndactor(p, y)
				if (p) y = 116-rnd(60-p)
				local alpha = "abcdefghijklmnopqrstuvwxyz"
				local a = {
					x=8+rnd(112),
					y=y,
					vx=1 - rnd(2),
					name=rndchar(alpha)..rndchar(alpha)..flr(rnd(1000))
				}
				add(actors, a)
				return a
			end
			for i=1,20 do
				rndactor(i*2)
			end
			local wide = "Œ”…‰‘‚†ŠŽ’–ƒ‡‹“—"
			for i=0,4 do
				local t = rndactor(nil, 127)
				t.vy = -1
				t.topic = rndchar(wide)..rndchar(wide)
				t.color = 8+i
			end
			player = rndactor(nil, 64)
			player.x = 64
			player.vx = 0
			score = 0
			timer = 1800
			state = nil
		end,
})

add(games, {
name="zapp-alike",
author="@adam_sporka",

_init=function(self)
	cx,cy,matrix,mask,score,t,started_at,pl=16,16,{},{},0,120,time(),true
	for a=0,1023 do
		matrix[a]=flr(rnd(2))+12
	end
	self:clear_mask()
end,

idx=function(x,y)
	return x+y*32
end,

clear_mask=function()
	for a=0,1023 do mask[a]=false end
	lx,ly=-1,-1
end,

toggle=function(self)
	i=self.idx(cx,cy)
	mask[i],lx,ly=not mask[i],cx,cy
end,

match=function(self)
	dx,dy=cx-lx,cy-ly
	if (lx<0) return
	success,count=1,0
	for x=2,29 do
		for y=2,29 do
			tx,ty=x+dx,y+dy
			if (mask[self.idx(x,y)]) then
				count+=1
				if (mask[self.idx(tx,ty)]) return
				if (matrix[self.idx(tx,ty)]!=matrix[self.idx(x,y)]) success=0
			end
		end
	end
	score+=success*count^2
	sfx(13-success)
	for a=0,1023 do
		if (mask[a] or mask[a-dy*32-dx]) matrix[a]=29+success
	end
	self.clear_mask()
end,

_update=function(self)
	t=flr(120-time()+started_at)
	if t<0 then
		if (pl) sfx(14)
		pl=false
		return
	end
	if (btnp(0)) cx-=1
	if (btnp(1)) cx+=1
	if (btnp(2)) cy-=1
	if (btnp(3)) cy+=1
	cx,cy=(cx-2)%28+2,(cy-2)%28+2
	if (btnp(4)) self:toggle()
	if (btnp(5)) self:match()
end,

draw_box=function(x,y,c)
	rect(x*4-1,y*4-1,x*4+3,y*4+3,c)
end,

_draw=function(self)
	cls()
	for x=2,29 do
		for y=2,29 do
			if mask[self.idx(x,y)] then self.draw_box(x,y,3) end
			spr(matrix[self.idx(x,y)],x*4,y*4)
		end
	end
	box_color=12
	if (mask[self.idx(cx,cy)]) box_color=11
	self.draw_box(cx,cy,box_color)
	spr(28,lx*4,ly*4)
	print("score "..score,8,121,7)
	s="game over"
	if (t>=0) s="time "..t
	print(s,84,121)
end
})

add(games,{
	name="freedom",
	author="zatyka",
	_init = function()

  text,tick,px,py,ps,pdy,pjmax,pjcnt,pspd,pf,solids,pwrups="              Â‹ freedom",0,200,91,21,0,1,0,3,0,{},{{384,408,"shrink"},{384,136,"shrink"},{176,440,"air jump"},{16,80,"speed"}}
		camera(136,27)
		for ix=0,31 do
			for iy=0,31 do
				tileval=mget(ix+96,iy)
				for i=7,0,0xffff do
					if (tileval>=2^i) s={(32*(i%2)+ix)*8, (16*flr(i/2)+iy)*8,rnd(4)}	add(solids,s) tileval-=2^i
				end
			end
		end
		function col(objs)
			for o in all(objs) do
				if(px<o[1]+8 and px+ps>o[1] and py<o[2]+8 and py+ps>o[2]) fobj,pwrup=o,o[3] return true		end
			return false
		end

	end,
	_update = function()
		tick+=1

		pf,colsol=0,{}
		for s in all(solids) do
			if (abs(s[1]-px)<50 and	abs(s[2]-py)<50) add(colsol,s)
		end

		if(btn(1)) px+=pspd xdirc,pf=1,tick%4
		if(btn(0)) px-=pspd xdirc,pf=0xffff,tick%4

		while col(colsol) do
			px-=xdirc
		end

		if((btnp(2) or btnp(4)) and pjcnt<pjmax) pdy=0xfff8	pjcnt+=1	sfx(16)
		pdy=min(pdy+1,14)
		py+=pdy
		local ydirc=sgn(pdy)
		if (pjcnt==0) pjcnt=1
		while col(colsol) do
			py-=ydirc
			pdy=0
			if (ydirc==1)	pjcnt=0
		end


		if col(pwrups)	then
			if pwrup=="air jump" then
				pjmax+=1
			elseif pwrup=="shrink" then
				ps-=7
			else
				pspd+=1
			end
			del(pwrups,fobj)
			sfx(17)
		end

	camera(mid(px-64,0,384),mid(py-64,0,384))
	if (px<0) text,py,px="   thanks for playing",0xfff8,64 sfx(18)
	end,
	_draw = function()
		cls()
		sspr(64+pf*8,40,7,7,px,py,ps,ps,xdirc==0xffff)

		for s in all(solids) do
			spr(120+s[3],s[1],s[2])
		end
		for pwr in all(pwrups) do
			local x,y = pwr[1],pwr[2]
				spr(105+x%3,x,y+sin(tick/25))
			print(pwr[3],x-8,y-7)
		end
		print(text,10,17)

	end
})
add(games, {
 name = "pikoban",
 author = "iko",

 _init = function(self)

  cubes = {}
  playerfacing, curlevel = 101, 0

  getspritecoords, drawthing, loadlevel =

  function(i)--getspritecoords

   if i==101 or i==102 then
    return 46,49,5,17
   elseif i>102 then
    return 51,49,5,17
   elseif i==5 then
    return 32,49,14,9
   elseif i<4 then
    return 32,32,17,17
   end
    return 49,32,15,17

  end,

  function(x,y,n)--drawthing

   local finalx, finaly = 56 + 8*x - 8*y, 24 + 4*x + 4*y
   local sx, sy, sw, sh = getspritecoords(n)

   finaly -= sh

   if n<4 then finalx -=1 finaly -=1 end

   if n > 100 then
    finalx += 5
    if playerh then finaly -= 10 end
   end

   if n == 2 then
    pal(7,15)
    pal(6,9)
    pal(13,4)
   end

   sspr(sx,sy,sw,sh,finalx,finaly,sw,sh,
    n == 102 or n == 103)--flipx

   pal()

   if n==3 then
    sspr(56,49,8,17,finalx+8,finaly-12)
   end
  end,

  function(lvl)

   playerx, playery, playerh, curlevel = 8, 8, false, lvl

   for x=1, 8 do
    cubes[x] = {}
    for y=1, 8 do
     cubes[x][y] = mget((lvl%4)*8+x+31,flr(lvl/4)*8+y-1)
    end
   end
  end

  loadlevel(0)

 end,
 _draw = function()


  local deltax, deltay  = 0, 0

  if     btnp "0" then deltax -= 1 playerfacing = 103
  elseif btnp "1" then deltax += 1 playerfacing = 101
  elseif btnp "2" then deltay -= 1 playerfacing = 104
  elseif btnp "3" then deltay += 1 playerfacing = 102
  elseif btnp "5" then loadlevel(curlevel) end

  local intendedx, intendedy, moveplayerintended =
   mid(1,playerx+deltax,8),
   mid(1,playery+deltay,8),
   false

  local intendedcubeindex = cubes[intendedx][intendedy]

  if intendedcubeindex==4 and deltay!=0 then

   playery, playerh = intendedy+deltay, not playerh

  elseif playerh then

   moveplayerintended = intendedcubeindex<3

   if intendedcubeindex==3 then
    loadlevel(curlevel+1)
   end

  else

   if intendedcubeindex==5 then

    moveplayerintended = true

   elseif intendedcubeindex==2 then

    local intplusx, intplusy = intendedx+deltax, intendedy+deltay

    if intplusx < 9 and intplusx > 0 and
       intplusy < 9 and intplusy > 0 and
       cubes[intplusx][intplusy] == 5 then

     cubes[intplusx][intplusy] = 2
     cubes[intendedx][intendedy] = 5
     moveplayerintended = true

    end
   end
  end

  if moveplayerintended then
   playerx, playery = intendedx, intendedy
  end

  cls()

  print(curlevel<15 and "picoban           level "..curlevel or "!congratulations the end!",13,0,13)

  for x=1,8 do for y=1,8 do
    drawthing(x,y,cubes[x][y])

   if x==playerx and y==playery then
    drawthing(playerx,playery,playerfacing)
    end

  end end

 end,
}
)
draw_rotated_sprite = function(spr, spr_x, spr_y, spr_ang)
  r=flr(spr_ang*20)/20
  s,c=sin(r),cos(r)
  b=s*s+c*c
  for y=-6,5 do
    for x=-6,5 do
      ox,oy=( s*y+c*x)/b, (-s*x+c*y)/b

      ax,ay,
      colr=ox+4,oy+4,
        sget(spr%16*8+ox+4,flr(spr/16)*8+oy+4)

      if ax>=0 and ax<8 and ay>=0 and ay<8 and colr>0 then
        pset(spr_x+4+x,spr_y+4+y,colr)
        color(7)
      end
    end
  end
end

add(games, {
 name = "bmx air king",
 author = "dollarone",

_init = function(self)
  music"28"
  self:startgame()
end,
startgame = function()
  timer,
  player_x,
  player_y,
  player_sprite,
  player_angle,
  player_speed,
  force,
  death_y,
  death_x,
  flips,
  score = 0,0,23,8,0,1,0.2,0,0,-1,0
end,

_draw = function()
  cls()
  map(0, 16, 0, 24, 16, 32)

  if death_y>1 then
    print(score, 10, 104)
    spr(43,death_x,death_y)
  else
    print("alternate \x8b and \x91 to speed up.\n in the air press \x8b and \x91 to\n spin and \x83 \x94 \x97 for tricks!\n     press \x8e to try again", 1, 100)
  end
  draw_rotated_sprite(player_sprite,player_x,player_y,player_angle)
end,

_update = function(self)
  timer+=player_speed
  if btn"4" then
    self:startgame()
  end

  if flr(timer)%3==0 then
    flips *= -1
    if player_sprite < 12 then
      player_sprite += flips
    end
  end

  if death_x==1 then
    if btn"0" then
      player_angle+=0.03125
    elseif btn"1" then
      player_angle-=0.03125
    elseif btn"5" then
      player_sprite = 27
    elseif btn"2" then
      player_sprite = 24
    elseif btn"3" then
      player_sprite = 25
    end
    score += flr(player_sprite/15)
  elseif btn"0" and death_y<0 or btn"1" and death_y==0 then
    death_y = abs(death_y)-1
    player_speed += 0.01
  end

  if death_x > 1 or timer < 8 then
    player_x+=player_speed
  elseif timer < 48 then
    player_angle = -0.125
    player_y+=player_speed
    player_x+=player_speed/2
  elseif timer < 63 then
    player_x+=player_speed
    player_angle = 0
  elseif timer < 68 then
    player_x+=player_speed
    player_y-=player_speed
    player_angle = 0.125
  else
    death_x = 1
    force *= 1.09
    player_y-=player_speed
    player_y+=force
    player_x+=player_speed
  end

  if player_y>71 then
    player_y,
    flips = 71,-1
    if (player_angle+0.1)%1 < 0.23 then
      score += player_speed*25 + abs(player_angle-0.125)*50
      death_x,
      player_sprite,
      death_y,
      player_angle,
      force = 999,8,2,0,"\nhighscore remains: " .. dget(29)
      if score>dget"29" then
        dset(29, score)
        force = "\n     new highscore!"
        sfx"17"
      end
      score = " nice jump! score: " .. score .. force
    else
      death_x,
      death_y,
      player_sprite,
      player_angle,
      score = player_x,player_y,10,0,"    ouch ouch ouch..."
      sfx"2"
    end
  end
end
})
add(games,{
	name = "piconaut",
	author = "josefnpat",
	_init = function()
		music"8"
		c = cameralib.new{height=64}
		draw_player = function(x,height)
			color"5"
			spr(192,x-16,48-height*32,4,2)
		end
		draw_tile = function(x,y)
			local r = y + off-1.5
			local i = (death or 0) - 2
			local size = 0.45
			local possizex,negsizex = size+x,-size+x
			local possizer,negsizer = size+r,-size+r
			local ia = {possizex,i,possizer}
			local ib = {possizex,i,negsizer}
			c:line(ia,ib)
			local ic = {negsizex,i,negsizer}
			c:line(ib,ic)
			local id = {negsizex,i,possizer}
			c:line(ic,id)
			c:line(id,ia)

			c:line(ia,ic)
			c:line(ib,id)
		end
		off = 0
		speed = 1
		score = 1
		jump_height = 0
		jump_v = 0
		player_x = 0
		player_y = 0
		death = nil

		map = {}
		chance = 0
		for j = -2,500 do
			chance += 1/500
			map[j] = {}
			for i = -2,2 do
				map[j][i] = rnd() > chance
			end
			map[j][flr(rnd"5")-2] = true
		end
	end,
	_update = function(self)
		player_y -= 1/30*speed
		off = player_y%1
		if not death then
			score += speed*0.05
			dset(8,max(score,dget"8"))
		end
		speed = btn"5" and min(5,speed+0.1) or max(1,speed-0.025)
		if btnp"4" and not death and jump_height == 0 then
			jump_v = 0.25
		end
		jump_v -= 0.025
		jump_height = max(0,jump_height+jump_v)
		if btn"0" then
			player_x += 0.1
		end
		if btn"1" then
			player_x -= 0.1
		end
		player_x = min(2,max(-2,player_x))
		if death then
			death += 0.1
		end
		rx = flr(player_x+0.5)
		ry = -flr(player_y)
		if jump_height == 0 and not map[ry][rx] then
			death = death or 0
		end
	end,
	_draw = function()
		cls()
		local perspective_x = c:_coordstopx{player_x,-2,0}
		for x = -2,2 do
			for y = -1,6 do
				ty = y-flr(player_y)
				if map[ty][x] then
					color( rx == x and 8 or y == 0 and 3 or 11)
					draw_tile(x,y)
				end
			end
		end
		color"5"
		draw_player(perspective_x[1],jump_height)
		sspr(0,112,32,16,32,96,64,32)
		color"7"
		print("    score:"..flr(score)..",000\ntop score:"..flr(dget(8,best))..",000\n\n")
		if death then
			print"off track - game over\nreset cart to play again\n\n\n\n\n\ncredits:\ncode: @josefnpat\nart: @josefnpat\nmusic: @josefnpat"
		else
			print(flr(speed*100).."km/h")
		end
	end
})
add(games,{
 name="zzzzap!",
 author="scathe",
 _init=function()
  t,a,b,et,ex,score,ea,ew,level,speed,timer,thresh,hiscore,rndxy,rndl=0,0,0,0,0,0,false,false,1,120,210,5,dget"0",function() return flr(rnd(6)+1)*16+1,flr(rnd(6)+1)*16+1 end,function(m) return m+flr(rnd(4)+1) end
  playerx,playery=rndxy()
  goalx,goaly=rndxy()
 end,

 _draw=function(self)
  cls()
  if not gameover then
   s2,i=speed/2
   timer-=1
   if(timer<=0) sfx"35" gameover=true
   rectfill(0,115,timer,117,8)
   if btnp"0" then
    if(playerx>17) playerx-=16 sfx"16"
   elseif btnp"1" then
    if(playerx<96) playerx+=16 sfx"16"
   elseif btnp"2" then
    if(playery>17) playery-=16 sfx"16"
   elseif btnp"3" then
    if(playery<96) playery+=16 sfx"16"
   end

   if playerx==goalx and playery==goaly then
    sfx"32"
    goalx=200
    score+=1
    timer+=60
    if(score>hiscore) dset(0,score) hiscore=score
    if(score%thresh==0) level+=1 thresh+=10*level/2 speed-=25
   end

   if goalx==200 then
    t+=1
    if(t==30) goalx,goaly=rndxy() t=0
   end

   for ny=1,6 do
    for nx=1,6 do
     ox,oy=nx*16+1,ny*16+1
     rectfill(ox,oy,ox+14,oy+14,6)
    end
   end

   map(64,0,0,0,16,16)
   rectfill(playerx,playery,playerx+14,playery+14,8)
   rectfill(goalx,goaly,goalx+14,goaly+14,11)

   et+=1
   if et>=speed then
    sfx"33"
    et,a,b,ew,ex=0,0,0,true,rndxy()
   end

   if ew then
    a+=1 b+=1
    spr(rndl(211),ex,9) spr(rndl(211),ex+8,9)
    if(b>=s2) sfx"34" b=0
    if a>s2 then
     for i=1,6 do
      d=i*16
      spr(228,ex,d)
      spr(229,ex+8,d)
      spr(230,ex,d+8)
      spr(231,ex+8,d+8)
     end
     if(playerx==ex) sfx"35" gameover=true
    end
    if(a>=s2+15) ew=false a=0
   end
  else
   print"\n\n\n\n\n\n\n\n           game over!\n\n        press \x97 to retry"
   if(btnp"5") gameover=false self._init()
  end

  print("score " .. score .. "       hi " .. hiscore .. "     level " .. level,0,122)
 end
})
mazes = {
 name = "infinite mazes",
 author = "fayne aldan",
 _init = function(self)
  for x=0,63 do
  	for y=0,63 do
  		mset(x,y,77)
  		if (x>48 or y>48) mset(x,y,0)
  	end
  end
  cx=1;cy=0;ax=0;ay=0;al=8
  tmr=0;win=false
  self:carve(1,1)
  mset(1,0,78)
  mset(47,48,79)
 end,
 _update = function(self)
  tmr+=1
  if win then
   tmr-=1
 	 if (btnp(4)) self:_init()
 	elseif ax!=0 or ay!=0 then
 	 al-=2
 	 if (al==0) ax=0;ay=0
 	else
	 	ox=cx;oy=cy;al=8
 	 if (btn(0)) cx-=1;ax=-1
   if (btn(1)) cx+=1;ax= 1
   if (btn(2)) cy-=1;ay=-1
   if (btn(3)) cy+=1;ay= 1
   if (mget(cx,cy)==79) win=true
   if (mget(cx,cy)!=78) ax=0;ay=0;cx=ox;cy=oy
  end
 end,
 _draw = function()
  cls();color(12)
  local t=flr(tmr/30)
  if win then
  	print("maze complete! time: "..t.." secs")
  	print("press ÂŽ for a new maze")
  else
	 	map(-9+cx,-9+cy,-12+ax*al,-12+ay*al,19,19)
 	 spr(76,60,60)
   print(t)
  end
 end,
 carve = function(self,x,y)
 	local r=flr(rnd(4))
  mset(x,y,78)
  for i=0,3 do
  	local d=(i+r)%4
  	local dx=0
  	local dy=0
  	if (d==0) dx= 1
  	if (d==1) dx=-1
  	if (d==2) dy= 1
  	if (d==3) dy=-1
  	local nx=x+dx
  	local ny=y+dy
  	local nx2=nx+dx
  	local ny2=ny+dy
  	if mget(nx,ny)==77 then
  		if mget(nx2,ny2)==77 then
  			mset(nx,ny,78)
  			self:carve(nx2,ny2)
  		end
  	end
  end
 end
}
add(games,mazes)
add(games,
{
 name="tank",
 author="mimick",
 _init = function()
  players=
  {
   {7,
    64,
    0,
    0
   },
   {120,
    64,
    0.5,
    0
   }
  }
  win,t=nil,nil
  for k,p in pairs(players) do
   p.player=k-1
   function p:draw()
    local a,p,timer = self[3],self.player,self[4]
    local rx,ry=self[1]+cos(a),self[2]-sin(a)

    timer=max(timer-1,0)
    if btn(1,p) then a+=1/128 end
    if btn(0,p) then a-=1/128 end
    if btn(2,p) then
     sfx"5"
     if pget(rx,ry)!=5 then
      self[1]=rx
      self[2]=ry
     end
    end
    if btnp(4,p) and timer==0 then
     sfx"3"
     timer=100
     add(bullet,{rx,ry,a,p==0 and 6 or 1,100})
    end
    self[3]=a
    self[4]=timer

    local x,y=self[1],self[2]
    local ca,sa=cos(a),sin(a)
    for i=-4,3 do
     local ci,si=i*ca,i*sa
     for j=-4,3 do
      local col=sget(100+i,68+j)
      if (col!=0) pset(x+(j*sa+ci),y+(j*ca-si),col)
     end
    end
   end
  end
  bullet={}
 end,
 _draw = function()
  if not win then
   for i=#bullet,1,-1 do
    local b=bullet[i]
    local x,y,ra,col,t=b[1],b[2],b[3],b[4],b[5]
    local ca,sa=cos(ra),sin(ra)
    if t==0 then
     del(bullet,b)
    else
     local rx,ry,boundx,boundy
     =ca*2+x,-sa*2+y,1,1
     if pget(rx,y)==5 then
      sfx"1"
      boundx=-1
      rx=x
     end
     if pget(x,ry)==5 then
      sfx"1"
      boundy=-1
      ry=y
     end
     if pget(rx,ry)==(col==1 and 7 or 0) then
      sfx"2"
      win=(col==1 and "\n\n\n\n\n\n\n\n\n\n\n\n          player 2" or "\n\n\n\n\n\n\n\n\n\n\n\n          player 1").." win"
     end
     ra=atan2(ca*boundx,sa*boundy)
     bullet[i]={rx,ry,ra,col,t-1}
    end
   end

   cls()
   rectfill(0,0,127,127,5)
   rectfill(2,2,125,125,13)
   rectfill(30,40,40,87,5)
   rectfill(87,40,97,87,5)
   for k,p in pairs(players) do
    if k==2 then pal(7,0) else pal() end
    p:draw()
   end
   for b in all(bullet) do
    pset(b[1],b[2],b[4])
   end
   if (win) then
    print(win)
    t=10
   end
  else
   t=max(t-1,0)
   if btnp"4" and t==0 then
    run()
   end
  end
 end
})
btnp_45=function()
 return btnp"4" or btnp"5"
end

add(games,{
 name="  tele",
 author="@rhythm_lynx\nmusic:  @robbyduguay",

 _init=function(self)
  poke(0x5f2c,3)
  music(4,1000)
  state,level,lx,ly,moves,restarts="title",1,16,16,0,0
  self.find_player()
 end,

 find_player=function()
  for x=0,7 do
   for y=0,7 do
    if(mget(lx+x,ly+y)==160)px,py=lx+x,ly+y
   end
  end
 end,

 find_telepad=function(dx,dy)
  x,y=px-lx,py-ly
  while x>0 and x<7 and y>0 and y<7 do
   x+=dx y+=dy
   if(fget(mget(lx+x,ly+y),1))return lx+x,ly+y,true
  end
  return 0,0,false
 end,

 _update=function(self)
  if state=="title" then
   if(btnp_45())state="game"
   return
  elseif state=="complete" then
   if(btnp_45())cgame=menu poke(0x5f2c,0)music(-1,1000)
  end

  if(btnp_45())reload(0x1000,0x1000,0x2000)self.find_player()restarts+=1

  count=0
  for x=0,7 do
   for y=0,7 do
    m=mget(lx+x,ly+y)
    if(fget(m,1))count+=1
    if(m==145)gx,gy=lx+x,ly+y
   end
  end
  if(count==0)mset(gx,gy,144)

  found=false
  if(btnp"0")newx,newy,found=self.find_telepad(0xffff,0)
  if(btnp"1")newx,newy,found=self.find_telepad(1,0)
  if(btnp"2")newx,newy,found=self.find_telepad(0,0xffff)
  if(btnp"3")newx,newy,found=self.find_telepad(0,1)
  if found then
   moves+=1
   px,py,m=newx,newy,mget(newx,newy)
   if m==144 then
    level+=1
    lx+=8 if(lx>24)lx=16 ly+=8
    if(level==5)state="complete"
    self.find_player()
   end
   m-=1 if(m==127)m=179
   mset(px,py,m)
  end
 end,

 _draw=function(self)
  cls"1"
  map(16,16,0,0,8,8,4)
  if state=="title" then
   rect(23,10,41,18,13)
   print("   tele\n\nmove\n\139\145\148\131\n\nrestart\n\142\151 (z/x)",
    13,12,6)
  elseif state=="complete" then
   rect(17,10,47,18,13)
   print("  you win\n\n"
    ..moves.." moves\n\n"
    ..restarts.." restarts\n\nwell done!",
    11,12,6)
  else
   map(lx,ly,0,0,8,8,1)
   spr(146,8*(px-lx),8*(py-ly))
  end
 end
})--game 12
add(games,
{
 name="boogie bash",
 author="jamish",
 _init = function()
  music"20"

  if highscore == nil then highscore = 0 end
  frame,
  score,
  offset,
  t,
  next,
  playerx,
  gameover,
  flips,
  obstacles,
  gaps,
  timeline =
   0,
   0,
   0,
   0,
   120,
   5,
   false,
   false,
   {},
   {},
   {0,2,8,20,31,32,32,32,32,32,32,10,5,2}

  function randomize(level)
   level = min(level,4)
   height = 0
   for i=1,8 do
    height += flr(rnd"5"-2)
    obstacles[i], gaps[i] = height, 0
   end
   color_floor, color_ceiling, color_bg = rnd"8"+8, rnd"8"+8, rnd"6"


   for i=4,level,-1 do
    gaps[flr(rnd"8")+1] = flr(rnd"2")+1
   end
  end

  function text(str, x, y)
   print(str, x, y+1, 1)
   print(str, x, y, color_text)
  end

  randomize()
 end,
 _update = function()
  if gameover then
   if btnp"4" then cgame:_init() end
   return
  end

  if next < t then
   randomize(flr(score/10)+1)
   score += 1
   next, highscore = t + max(80-score,35), max(score, highscore)
  end

  remaining = next-t
  if remaining < 14 then
   offset = timeline[remaining+1]
  elseif remaining < 30 then
   offset = t%2*2
  end
  if remaining == 10 then
    sfx"2"
  end

  if 4 < remaining and remaining < 11 then
   frame = 32
   if gaps[playerx] < 2 then
    frame = 33
   end
   if gaps[playerx] < 1 then

    music"-1"
    gameover = true
   end
  else

   if btnp"0" then
    playerx -= 1
   elseif btnp"1" then
    playerx += 1
   end

   if t%3 < 1 then

    frame, flips = rnd"4"+16*flr(rnd"2"), rnd"2" < 1
   end
  end

  playerx = (playerx-1)%8+1
  t+=1
 end,
 _draw = function()

  rectfill(0,0,128,128,color_bg)


  for j=0,128 do for i=0,7 do
   line_x = i*16
   obstacle_y = obstacles[i+1]*4
   line_y_ceiling, line_y_floor = 48-obstacle_y-gaps[i+1]*8+offset-j, 80-obstacle_y+j
   temp_color_ceiling, temp_color_floor = color_ceiling, color_floor
   if j<4 and j~=2 then
    temp_color_ceiling -= 1
    temp_color_floor -= 1
    color_text = temp_color_ceiling
   end
   line(line_x, line_y_floor, line_x+15, line_y_floor, temp_color_floor)
   line(line_x, line_y_ceiling, line_x+15, line_y_ceiling, temp_color_ceiling)
  end end


  color(color_text)
  playery = 72-obstacles[playerx]*4
  if gameover then
   frame = 34
   playery += 5
   text("press \x8e/z to restart", 23, 110)
  end

  spr(136+frame, playerx*16-12, playery, 1, 1, flips)
  text("score: "..score.."\n high: "..highscore, 2, 2)
 end
})


-----------------------------------------------------------------



add(games,{
 name = "snek over 16",
 author = "lemtzas\nhiscore: " .. dget"42",
 ----------------------- init --
 _init = function(self)
  -- polluting the globals with my data
  t,food = 1,0
  -- snek
  s_dir, s_x,s_y = nil, 10,10
  s_len, s_tail, s_run_id = 3, {}, flr(rnd"32767")

  -- map initialization
  for x=0,63 do
   for y=0,63 do
    sset(x,y,0)
   end
  end
 end,

 update_snek = function(self)
  if s_done then
    local tail_end = s_tail[1]
    del(s_tail,tail_end)
    return tail_end and sset(tail_end.x,tail_end.y,8)
  end

  -- input
  s_dir =
   btn"0" and s_dir ~= 1 and 0 or
   btn"1" and s_dir ~= 0 and 1 or
   btn"2" and s_dir ~= 3 and 2 or
   btn"3" and s_dir ~= 2 and 3 or
   s_dir
  if btn"4" then self:_init() end
  if not s_dir then return end

  local p_x,p_y = s_x,s_y
  s_x =
   s_dir == 0 and s_x - 1 or
   s_dir == 1 and s_x + 1 or
   s_x

  s_y =
   s_dir == 2 and s_y - 1 or
   s_dir == 3 and s_y + 1 or
   s_y

  -- pausing on walls
  if s_x < 0 or s_x > 63 or
     s_y < 0 or s_y > 63 then
   s_x,s_y = p_x,p_y
   return
  end

  -- sliding
  s_tail[#s_tail+1] =
   {
    x = p_x,
    y = p_y
   }
  local old = s_tail[1]
  local new = s_tail[#s_tail]
  sset(old.x,old.y,0)
  sset(new.x,new.y,6)
  if #s_tail > s_len then
   for i=1,#s_tail do
    s_tail[i] = s_tail[i+1]
   end
  end

  local target = sget(s_x,s_y)
  if target == 11 then
    s_len = s_len + 1
    food = food - 1
    if s_len > dget"42" then
      s_winning = dget"43" ~= s_run_id and sfx"47" or true
      dset(42,s_len)
      dset(43,s_run_id)
    end
    sfx(s_len % 10 == 0 and 45 or 44)
  elseif
    s_dir ~= nil and
    target ~= 0 then
    sfx"46"
    s_done = true
  end

  sset(s_x,s_y,8)
 end,

 --------------------- update --
 _update = function(self)
  function r_grid()
   return flr(rnd"63")
  end
  t=t+1

  if t % 2 == 0 then
   self:update_snek()
  end

  if t % 30 == 0 and food < 10 then
   local x,y = r_grid(), r_grid()
   sset(x,y,sget(x,y) == 0 and 11 or 0)
   food = food + 1
  end
 end,

------------------------ draw --
 _draw = function(self)
  cls()
  print("hiscore " .. dget"42", 1, 1, s_winning and 12 or 1)
  print("  score " .. s_len, 1, 7, 1)
  sspr(0,0,64,64,0,0,128,128)
 end
})
games[#games]:_init()
cgame = games[#games]

-----------------------------------------------------------------


add(games,{name="videopirate",author="team_disposable",

_update = function()

	cls()

	if notgameover then

		if cliptimer <= 0 then

			if (#obs > 0 or success == 15) notgameover = false


			size1,size2,rand = rnd"6.9"*8,rnd"6.9"*8,rnd"3.9"

			obs = {}

			for i=1,success,1 do

				add(obs,{i,flr(rnd"4"),11})

			end

			cliptimer += 100

				sprite1x,sprite1y,sprite2x,sprite2y = 32,64,40,64

				if(rand < 3) sprite1y = 80

				if(rand < 2) sprite1y,sprite2y = 72,80

				if(rand < 1) sprite1y,sprite2y = 64,72

		end



		adjust,adjust2 = rnd"8",rnd"8"

		sspr(sprite1x,sprite1y,8,8,32+adjust,40+adjust2,size1,size1)

		sspr(sprite2x,sprite2y,8,8,60+adjust2,40+adjust,size2,size2)



		if #obs == 0 then
			success += 1  cliptimer = 0

		else

		o = obs[1]
		o1,o2,o3 = o[1],o[2],o[3]
		if o1 == 1 then


			if (btnp"5" and btnp"4") o3 = 0

			sspr(32,88,8,8,40,50,40,40)


		elseif o1 == 2 then

			if(btnp"4") o3 -= 2
			liney = rnd"40"+29
			for i = 19,109,5 do

				line(i,liney,i+o3,liney+o3,14)

			end


		elseif o1  < 11 then

			if btn(o2) then o3 -= 2 end


			spritex,flipped = 48,false


			if o2 == 1 then flipped = true

			elseif o2 == 2 then spritex = 56

			elseif o2 == 3 then spritex = 56 flipped = true end

			sspr(spritex,72,8,8,50,50,24,24,flipped,flipped)

			for i=1,o3,1 do
				for j=1,20,1 do

					pset(rnd"90"+19,rnd"80"+19,o2+1)


				end

			end

		else

			bumpat -= 4
			if bumpat < 19 then bumpat = 109 end

			bmpcolour = 9

			if bumpat < 74 and bumpat > 54 then
				bmpcolour = 11
				if btnp"5" then o3,bumpat= 0,15   end

			end

			for b = 40+adjust,80,5 do
				line(19,b,bumpat,b,bmpcolour)
				line(bumpat+8,b,109,b)
				spr(181,bumpat,b-8)
			end


		end

		o[3] = o3
		if(o3 <= 0.1) del(obs,o) cliptimer += 35

		cliptimer -=1

		print(cliptimer,85,20)

	end



else
		cursor(20,28)

		if success == 15 then
			print"your collection\nis superb. \nvhs will never die,\nyou gloat\n\n\n\n\npress z to restart"

		else
			print"no one said piracy\nwas easy.\n\nz+x to break copyright\narrows reduce static\nz to remove scanlines\nx in time to lock on\n\npress z to restart"

		end


		if(btnp"4") cgame:_init()
end

	sspr(48,80,16,16,4,4,120,120)

	spr(134,30,110,2,1)
	print(success,50,110)


end,

_init = function(self)

		notgameover,cliptimer,success,bumpat,obs = true,0,0,0,{}
		music"0"

	end})
add(games,{
name="\nb\76\79\66\66\89 b\79\66\66\89 a\78\68\nt\72\69 b\73\71 b\82\69\65\75\79\85\84",
author="@seansleblanc",
_init = function()
 t,l,
 p_x,p_y,p_z,
 p_vx,p_vy,p_vz,
 camera=
 0,10,
 0,0,0.6,
 0,0,0,
 cameralib.new()
 camera.z=0xffffff

 blobs={}
 for i=1,8 do
  add(blobs,{})
 end
 music"60"
end,
_draw = function()

 for i=1,666 do
  print("-\152-",rnd"131"-8,rnd"131",2)
 end

 if btn"0" then p_vx+=0.0625 end
 if btn"1" then p_vx-=0.0625 end
 if btn"2" then p_vy+=0.03125 end
 if btn"3" then p_vy-=0.03125 end
 if btn"4" then p_vz-=0.001 end



 color"8"

 camera:line({0xfffffd,0xffffff.4,1},{0xfffffd,0xffffff.4,99})
 camera:line({3,0xffffff.4,1},{3,0xffffff.4,99})
 camera:line({3,2,1},{3,2,99})
 camera:line({0xfffffd,2,1},{0xfffffd,2,99})

 for i=1,2,0.0625 do
  local d=(i+p_z)%1*99

  camera:line({0xfffffd,0xffffff.4,d},{0xfffffd,2,d})
  camera:line({3,0xffffff.4,d},{3,2,d})
  camera:line({0xfffffd,0xffffff.4,d},{3,0xffffff.4,d})
  camera:line({0xfffffd,2,d},{3,2,d})
 end


 for i,b in pairs(blobs) do

  local z,seed2=b.z or 0,
  i/max(1,30+p_z)+p_z
  local p1={sin(seed2/2.123),cos(seed2/2.321),(i+p_z)%1*99}
  p2,b.z=camera:_coordstopx(camera:_perspective(p1)),p1[3]


  if b.z-z > 0 then
   if abs(p1[1]-p_x)+abs(p1[2]-p_y) < 1 then
    rectfill(0,0,127,127)
    sfx"61"
    l-=1
   else
    sfx"60"
   end
  end

  local x,y,z=p2[1],p2[2],min(100,10/sqrt(b.z))
  circfill(x,y,z,2)
  circ(x,y,z-1,8)
 end




 a_tx,p_p2=p_x*6,camera:_coordstopx(camera:_perspective({p_x,p_y,1}))

 camera.theta=a_tx/0xffff6a
 local px,py,r=p_p2[1],p_p2[2],24-abs(a_tx)
 circfill(px,py,r,2)
 circ(px,py,r,8)
 circfill(px+a_tx,py+5*p_y,r/2.5)

 print("\nd:"..max(p_z*0xfffff6).."\nt:"..t.."\nl:"..l,1,1)

 if l>0 then

  t+=1
  p_z+=p_vz
  p_x+=p_vx
  p_y+=p_vy

  p_vz*=0.97
  p_vx*=0.9
  p_vy*=0.9

  p_x*=0.7
  p_y*=0.8
 else

  print"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n           you lost!\n\n     press \151 to continue"
  if btnp"5" then run() end
 end
end})
__gfx__
1111111105000050ff008000111111110000000000000000000000000000000000000ff00000ff00000000000000000088800000770000000000000000000000
1222222155555555dd0888001ccdd99102222222222222200dddddddddddddd0000ccff000ccff00000000000000000088800000777000000000000000000000
1211112105c00c50c00080ff1cc1191102000000000000200d000000000000d000cccc000cccc000000005500000055088000000777000000000000000000000
38888883050cc050cc0000ff1c11911108888888888888800cccccccccccccc00022cf500222cf50000000500000005000000000000000000000000000000000
82828288050cc050c00000dd111911c18882828228282888ccc1c1c11c1c1ccc0622226006222560065555600655556000000000000000000000000000000000
8282828805c00c50000ff00011911cc18882828228282888ccc1c1c11c1c1ccc6564225665622656656506566565565600000000000000000000000000000000
5688886555555555000ff000199ddcc1568888888888886565cccccccccccc566065460660644606606556066060060600000000000000000000000000000000
5655556505000050f00ee00b11111111560000000000006565000000000000560600006006000060060000600600006000000000000000000000000000000000
07777700116666110000ff00b0b88b0b33336655555555555566313133333333000ff0f00f0ff00000000ff0002cccff00000000655500000000000000000000
770007001666666100ccff000b0880b033366555555555555556631333131333fccffcc00ccffccf000ccff0022cccff0a000000666600000200000000000000
700707001d6666510cccc0000b8008b03366555555555555555566333331333300ccc00000ccc00000cccc0042200c0000000005565000000000000000000000
770007001dd665510222cf50b088880b3665555555555555555556633333333305c2205005c220500222cf5040000c5000000006666000000000000000000000
077770001ddd555106222560b800008b6655555555555555555555663333313106522560065225604222556006555f6000000000000000000000000000000000
070070001ddd55516562265608888880655555555555555555555556333333136562265665622656456506566565065600000000000000000000000000000000
5555555011dd551160644606dddddddd555555555555555555555555333333336064460660644606606556066065560600000000000000000000000000000000
22222250111d511106000060d666666d555555555555555555555555333333330600006006000060060000600600006000000000000000000000000000000000
0800008044444444ddddddddeeeeeeee666666661111111111111111111111118000000022228000800000000000000000000000000000000000000000000000
8880088846666664d0d0dddde111111e155555561111111111171111111111118000000022228000800000000000000000000000000000000000000000000000
08c0cc8046464444d000dddde1e1111e151151161111111111111111111111112800000022222800280000000000000000000000000000000000000000000000
000c000044466664dd0ddddde111111e155555561111111111111111111111112800000022222800280000000000000000000000000000000000000000000000
00c00c0046664644ddddd7dde111111e151151161111111111111111111111112280000022222280228000000000000000000000000000000000000000000000
08ccc08044464644dddd777de1e11e1e155555561111111111111111111711112280000022222280222800004000000000000000000000000000000000000000
8880088846664664dddd7d7de111111e15115116111111111111111111111111222800002222222822228800422cccff00000000000000000000000000000000
0800008044444444ddddddddeeeeeeee15555556111111111111111111111111222800002222222822222288022fccff00000000000000000000000000000000
dddffddf000000000555555088888888555555553333333311111111333333332222222222222228000000000000000000000000000000000000000000000000
ddd66dcd007777700566665088222288555775553313133311777711331313332222222222222228000000000000000000000000000000000000000000000000
ddccccdd0b700b700656656082888828555775553331333317776771333133332222222222222228000000000000000800000000000000000000000000000000
ececceee0070b0700666666082822828555775553333333317777571333333332222222222222228000000000000008800000000000000000000000000000000
99f11999007000705000000d82822828555775553333313117777771333331312222222222222228000000000000082800000000000000000000000000000000
aaa1a1aa000087700555ddd082888828555775553333331617777771633333132222222222222228000000000008822800000000000000000000000000000000
aa11aa1a000000000ddd555088222288555775553333336611777711663333332222222222222228000000008882222800000000000000000000000000000000
aa8aaaa800000000d000000588888888555555553333366511111111566333332222222222222228888888882222222800000000000000000000000000000000
00044400000000005555555555555555000000066600000000000000660000000000000000000000000000000000000000000000888488846767676767676767
004ffff0000000005565555555555655000006677766000000000001dd6600000000000000000000000000000000000000011000444444447676767676333376
004f3f3000088000560666666666606500066777777766000000001666dd66000000000000000000000000000000000000155100848884886767676767333367
004ffff00088e800556000000000065506677777777777660000001dd666dd610000000000000000000000000000000001555510444444447676767676333376
000fff000888888055600000000006551d77777777777771100001666dd666110000000000000000000000000000000001555510888488846767676767476767
0fddd0000d888880556000000000065516dd77777777711d100001dd666dd6110000000000000000000000000000000000155100444444447676767676467676
00dddf0000d8880055600000000006551666dd7777711ddd10001666dd6661d10000000000000000000000000000000000011000848884886767676767476767
00404000000dd0005560000000000655166666dd711ddddd10001dd666dd61d10000000000000000000000000000000000000000444444447676767676767676
55600000000006555560000000000655166666661ddddddd1001666dd6661dd10777777007777770077777700777777000000000000000000000000000000000
55600000000006555560000000000655166666661ddddddd1001dd666dd61dd17700007077000070770000707700007000000000000000000000000000000000
55600000000006555560000000000655166666661ddddddd101666dd6661ddd17000707070007070700070707000707000000000000000000000000000000000
55600000000006555560000000000655166666661ddddddd101dd666dd61ddd17000007070000070700000707000007000000000000000000000000000000000
55600000000006555560000000000655166666661dddddd111666dd6661dddd17700077077000770770007707700077000000000000000000000000000000000
55600000000006555606666666666065011666661dddd1100116666dd61dd1100777770007777700077777000777770000000000000000000000000000000000
55600000000006555565555555555655000116661dd110000001166661d110000700070007000700700070007000700000000000000000000000000000000000
55600000000006555555555555555555000001161110000000000116611000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555555555555555555000000011000000000000001100000000000000007777770077777700777777000000000000000000000000000000000
00000000555555555555555500000000000000dd000000009000090000000000000000007788887777bbbb7777cccc7700000000000000000000000000000000
000000006666666655555555000000000000dd55dd0000097100999000ddd00000000000787788877b77bbb77c77ccc700000000000000000000000000000000
0000000000000000555555550000000000dd555555dd0001778079780d111d0000000000787888877b7bbbb77c7cccc700000000000000000000000000000000
00000000000000005555555500000000dd5555555555dd0777002770d16661d000000000788887877bbbb7b77cccc7c700000000000000000000000000000000
6666666600000000555555550000000055555555555555027e2222201666661d00000000788877877bbb77b77ccc77c700000000000000000000000000000000
55555555000000005555555555555555dd5555555555dde22e22e22e1666661d000000007788887777bbbb7777cccc7700000000000000000000000000000000
5555555500000000555555555555555500dd555555dd00e22e22e22e166666610000000007777770077777700777777000000000000000000000000000000000
000000000000000000000000000000000000dd55dd0000eccc22ccce166666615555555555555555555555555555555500000000000000000000000000000000
00000000000000000000000000000000000000dd000000ec0c72c0c7166666d152222225577777755dd11dd55666666500000000000000000000000000000000
00000000000000000000000000000000888888888888887c0c07c0c01666ddd15222dd25575555755dddddd55677776500000000000000000000000000000000
00000000000000000000000000000000888888888888880c0c00c0c016ddddd15222dd255755557551dddd155676676500000000000000000000000000000000
00000000000000000000000000000000888888888888880c0c00c0c01dddddd152dd22255755557551dddd155666676500000000000000000000000000000000
00000000000000000000000000000000888888888888880c022022c0011dddd152dd2225575555755dddddd55777776500000000000000000000000000000000
0000000000000000000000000000000088888888888888022000002200011dd152222225577777755dd11dd55666666500000000000000000000000000000000
00000000000000000000000000000000888888888888880000000000000001115555555555555555555555555555555500000000000000000000000000000000
4444444499999999eeeeeeeecccccccc040440000000000055555555555555550f0ff00f0000000008000080000ff00000000000000000000000000000000000
4000000490000009e000000ec000000c044440000002200055577777777775550c0660c0000ff000001001000006600007777000000000000000000000000000
4000000490900009e0e0000ec0c00c0c44ffff0000222200557755777755775500cccc000f0660000011100000cccc0007777000000000000000000000000000
4000000490000009e000000ec000000c4ff5f500004542005775665775665775000cc0000ccccccf000110000c0cc0c000077770000000000000000000000000
4004000490000009e000000ec000000c4fffff0004444200677566577566577600011000000cc000cccccc000f0110f000077770000000000000000000000000
4000000490000909e0e00e0ec0c00c0c0fffff000044422067775577775577760010010000111100f00660c00010010007777000000000000000000000000000
4000000490000009e000000ec000000c0ffff0000000022067777777777777760100010001000010000ff0c00010010007777000000000000000000000000000
4444444499999999eeeeeeeecccccccc000f00000000000066666666666666660800080000800800000000f00080080000000000000000000000000000000000
333333336666666600000000d0d0d0d00099990000055555000000000008000000000000000000000f0ff000000ff00000000000000000000000000000000000
333333336666666608888880d0d0d0d0099aaa990044444500088d0000888000000ff000000ff0000c0660f00006600000000000000000000000000000000000
3300003366000066080000800d0d0d0d99aa4a49044444450088d000088d880000066000000660f000ccccc000cccccf00000000000000000000000000000000
3303303366066066080000800d0d0d0d99aaa99955555445088d000088d0d8800cccccc00cccccc0000cc0000c0cc00000000000000000000000000000000000
330330336606606608000080d0d0d0d009aa99905667540588d000008d000d800f0cc0f00f0cc0000001100000f1100000000000000000000000000000000000
330000336600006608000080d0d0d0d0099a999056775000088d0000d00000d00011110000011100000101000011110000000000000000000000000000000000
3333333366666666088888800d0d0d0d00999900555550000088d000000000000010010000010100001000800010010000000000000000000000000000000000
3333333366666666000000000d0d0d0d009990005000500000088d00000000000080080008110800008000000080080000000000000000000000000000000000
c000000c00000000000000000000000000000000004004000055555555555500000ff00f00000000000000000000000000000000000000000000000000000000
0c0000c000000000000000000000000000000000004004000544444444444450000660c000000000008000000000000000000000000000000000000000000000
00c00c000000000000000000000000000000000000444400544000000000044500cccc0000000000000000800000000000000000000000000000000000000000
000cc000000000000000000000000000606000000054450054000000000000450c0cc00000000008008888800000000000000000000000000000000000000000
000cc0000000000000000000000000005650006040444404540000000000004500f11000ff0cc010282822820000000000000000000000000000000000000000
00c00c00000000000000000000000000666d6d600446644054000000000000450001010066c0f100088082080000000000000000000000000000000000000000
0c0000c000000000000000000000000000dd6d6000444400540000000000004500110010fccc1100000008000000000000000000000000000000000000000000
c000000c0000000000000000000000000006006004000040540000000000004500800008cccc1118800802080000000000000000000000000000000000000000
00000000000000000000000000000000006666000000900054000000000000450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000060550600009900054000000000000450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000605005060009900054000000000000450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000605000060009900004444444444444400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000605005060090090005555666666555500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000060550600090090005555555555555500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006666000900009005000000000000500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000009000000905000000000000500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000cccccccccccccccc0675000000006750aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa05555555555555555555555000000000
00000000000000000000000000000000c777777777cccccc0675000000006750aaaaaa0aaa0aaaaaaaaaaaaaaaaaaaaa55000055550000555500005500666600
00000000000000111100000000000000c7ccccccccccccc10675000000006750aaaaaa0aa0aaaaaaaaaaaaaaaaaaaaaa50000005500000055000000506000060
00000000000001cccc10000000000000ccccccccccccc1110888000000008880aaaa0000000000000aaaaaaaaaaaaaaa50000005500000055000000506000060
0000000000011111111110000000000006750000000067508788800000087888aa00a00a00aaaaaaa00aaaaaaaaaaaaa50000005500000055000000506000060
0000000000dddddddddddd000000000006750000000067508888800000088888aa0000aaaaaaaaaaaa00aaaaaaaaaaaa50000005500000055000000506000060
0000dddddddddd5555dddddddddd000006750000000067508888200000088882aaaaa0a0000000000aa0aaaaaaaaaaaa55000055550000555500005500666600
000d1111dddd55511555dddd1111d00006750000000067500882000000008820aaaa0000aaaaaaaa0aaa0aaaaaaaaaaa55555555555555555555555500000000
00d1aaaa1ddd551dd155ddd1aaaa1d0000000000000000000000000000000000aaa000aaaaaaaaaa0aaa0aaaaaaaaaaa55555555555555555555555500000000
0d1a9998a1d551dddd155d1a8999a1d000000000000000000000000000000000aaaaaaaaaaaaaaaa0aaa0aaaaaaaaaaa55000055550000555500005500999900
dd18884481d551dddd155d18448881dd000ccc000000000c000000ccc000000caaaaaaaaaaaaaaa00aaa0aaaaaaaaaaa50000005500000055000000509000090
dd1a9998a1d551dddd155d1a8999a1ddc0cc0c00ccc00ccc0ccc0cc0cc0000ccaaaaaaaaaaaaaaa0aaa00aaaaaaaaaaa50000005500000055000000509000090
00d1aaaa1dd5551111555dd1aaaa1d000cc00ccc00cccc00cc0ccc000ccccc00aaaaaaaaaaaaa000aaa0aaaaaaaaaaaa50000005500000055000000509000090
000d1111d00dd555555dd00d1111d00000000000000cc000c0000000000cc000aaaaaaaaaaaa00aaaa00aaaaaaaaaaaa50000005500000055000000509000090
0000000000000dddddd000000000000000000000000000000000000000000000aaaaaaaaaaa0aaaaa0aaaaaaaaaaaaaa55000055550000555500005500999900
0000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa00aaaa00aaaaaaaaaaaaaaa55555555555555555555555500000000
000000006666666666666666000000000c00c00000cc00c00cc000c000cc0cc0aaaaaaaaa00aa000aaaaaaaaaaaaaaaa5555555555555555555555559aaaaaa9
000000663333363553633333660000000c00ccc000c00cc00c000cc00cc000c0aaaaaaa00aaa00aaaaaaaaaaaaaaaaaa550000555500005555000055a900009a
000066555755335b55335555556600000c000cc000c00c000cc00c000c0000c0aaaaaaa0aa0a0aaaaaaaaaaaaaaaaaaa500000055000000550000005a090090a
00663355b75535555b53b5bb5b3366000cc00c0000cccc0000cc0cc00cc00cc0aaaaaa00aa0a00aaa00aaaaaaaaaaaaa500000055000000550000005a009900a
663333775ab535b5555355555533336600cc0c0000cccc00000c0c0000c00c00aaaaaa00aaaaa0000000aaaaaaaaaaaa500000055000000550000005a009900a
3333335ba5773355b533bb5bb5333336000c0cc00cc00c000cc00c0000c00c00aaaaaaa00000000000aaaaaaaaaaaaaa500000055000000550000005a090090a
36d333557b553635536355555533386300cc00c000c00c000c000cc000ccccc0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa550000555500005555000055a900009a
36d23355755533333333bbb5bb33886300c000c000c000c00c0000cc0000c0c0a00aa00aaaaa00aa0aaaaaaaaaaaa0aa0555555555555555555555509aaaaaa9
3612d33333335556655533333338896300000000000000000000000000000000a0a0a0a0aaa0aaa000a00aa000aaa0aa0000000000000000c000000c08888880
361ed35555555ff6665555555538996307777000000000000000000000000000a0a0a0a0aaa00aaa0aa0a0a0a0aaa0aa00000000000000000c0000c080000008
36de1355d1115ff66655511d55399a6307770000000000000000000000000000a0a0a000aaaaa0aa0aa000a0a0aaa0aa00c00c000008800000c00c0080000008
36d21355d1115ff66ff51111d539aa6307700000000000000000000000000000aaaaaaaaaaa000aa0aa0aaa000aaa0aa000cc00000800800000cc00080000008
3362d35d11115ffffff51111d53aab6307000000000000000000000000000000aaaaaaaaaaaaaaaaaaaa00a0aaaaa0aa000cc00000800800000cc00080000008
3336d35d111155fffff51111d53abb6300000000000000050000000000000000aaaaaaaaaaaaaaaaaaaaaaa0aaaaaaaa00c00c000008800000c00c0080000008
3333635d111115f999945111d53bb63300000000000000050000000000000000aaaaaaaaaaaaaaaaaaaaaaa0aaaaa0aa00000000000000000c0000c080000008
3333335d1111154999945111d53b633300000000005555550000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000000000c000000c08888880
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030300000000000000000000000003010004000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
252525252525252525252525252525256363636363636363636363636363636305050505050305050505050103010505050501010301010505010101030101010000c4c5c4c5c4c5c4c5c4c5c4c5000000000000000000000000000000000000df030313038383232b57c3030303a303474763670703038303030b03434343ef
252525252526272525252525252627256262626262626262626262626262626205050505050105050505050505050505050505050105050505010505010505010000c6c7c6c7c6c7c6c7c6c7c6c70000000000000000000000000000000000005c000000008080202c54c0000000a100848480c04000008002020a02020202ae
252636252525252525252526272525256262626262626262626262626262626205050505050505050505050505050205050505050505050505010505050505010000f400f400f400f400f400f4000000000000000000000000000000000000005f434202020606064e54d0100002a3020626a2e37313118103030b0a020212be
25252525252525252627252525252525626262626262626262626262626262620505050505010505050505010101050505050505010505050505020505010505000000f500f500f500f500f500f50000000000000000000000000000000000005d110101010100000054c0400000a808042c84c4444040c0c2820a02020212be
252526272525252525252525262725256262626262626262626262626262626205050502050405050505050504050505050505050505020505050501050505050000f400f400f400f400f400f400000000000000000000000000000000000000d5818181010101010155c0400000a00a062a82c24242424242c24a42424242ee
25252525252627252525262725252525426161616161616161616161616161430505050505050505050505050505050505010201050102050505020501010205000000f500f500f500f500f500f50000000000000000000000000000000000005d0d09998181c1c14155c04040406008042890d05252424242820a02020202ae
252627252525252525252525252525255000000000000000000000000000005105050505050505050505020505050505050505040505050501050105040505050000f400f400f400f400f400f4000000000000000000000000000000000000005d4d09090101018101150000000020080428d0d01212020202020a02020202ae
25252525252526272525252525262725500000000000000000000000000000510505050505050505050505050505050505050505050505050505050505050505000000f500f500f500f500f500f5000000000000000000000000000000000000554501010101018111150000000020000428f0b01212120202020a02020202ae
252525262725252525262725252525255000000000000000000000000000005101030101050505050305010101010101030101050505010101050505050503050000f400f400f400f400f400f40000000000000000000000000000000000000055454501010121a1a1b1b0108080a08084a8f0b0121212020202020202020aae
25252525252525252525252525252525500000000000000000000000000000510501010505050505050505050505050101010505020505040502020502050105000000f500f500f500f500f500f500000000000000000000000000000000000055444010120202222231200000002048486860201252524202020202028292be
252525252525252525252525252525255000000000000000000000000000005105050205050505050105010105050205010501050505010505050502050105050000f400f400f400f400f400f40000000000000000000000000000000000000055444000000000000415240000002000002820201240404141010101018190be
17171735141515341515151637171717500000000000000000000000000000510501050105050505010501010105050501050501050105050505050505010505000000f500f500f500f500f500f5000000000000000000000000000000000000d5c4c040404000000011341010102206062e22220341414140000000008080ae
171735141515151515151515163717175000000000000000000000000000005105050205020505050105050405050505010501010501010501010505050505050000f400f400f400f400f400f40000000000000000000000000000000000000055514141416160405011240000002202062e26230341414140000000008080ae
17351415151515341515151515163717500000000000000000000000000000510501050105010505010505050505050501050505050505050101010501050505000000f500f500f500f500f500f500000000000000000000000000000000000055404040406160404011240000002202022e27232260606042020200008080ae
351415151515151515151515151516375000000000000000000000000000005105050205050405050105020505050505010505020502050505040505050505050000000000000000000000000000000000000000000000000000000000000000574242424263634242d3a20202023a12131b07060241416143030301018189ab
141515151515153415151515151515165260606060606060606060606060605305050505050505050101050505050505010505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000f5c0c0c0d0f0f0c0c2d1e1c1c0d0f8d0d1d9d8c4c5c1c0e0c2c2c2c0c0c0c0fa
3a00000000000000000000000000000093939393939393939393939393939393010505050505050305010105030501050301010505050101050101030101050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3828000000000000000000000000000093a0b3b3b3b3b39393b380b3b380b393010501010501050105050502050505050105050505050504050501010105050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3829000000000000000000000000000093b391b38080b3939380b3a0b3b38093010505010505050505010102010105050105010105010105050205040502050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838280000000000000000000000000093b3b3b3b3b3b39393b3b3b3b3b3b393010105010501050105010505040505010105050505050505050502020205050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
38382900000000000000000000000000938282b3b381b39393b3b3b3b3b3b393010105010501050405010505050505050105050105010505050205020502050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838382a3a3a3b00000000000000000093b3b3b3b3b3b3939380b3b3b3838193010502050501050505010102010101010105050505050505050205050502050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
383838383838393a3a3a3a3a3a3a3a3a9380b3b38080b39393b380b3b3819193010505050505050505050502050505050105050202020505050502020205050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838383838383838383838383838383893939393939393939393939393939393010505050101050505020505050505050105050505050505010502050205010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838383838383838383838383838383893939393939393939393939393939393030505050502050501050101030101050305050501010101050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000093b3b3b3b3b3b3939380b3b380b3b393010505010105020501050205050502050505050502050501050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000093b3808280b3b39393b3b3b3b3b3b393050501010502010505050505050505050505050105050205050505010505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000093b3818381b3919393b3b38381b38293050505050502050505050505050505050505010502020505050501020105050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000093b3808280b3b3939380b381a0b3b393050501010502010501050105050501050102050205050505050505040505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000093b3b3b3b3b3b39393b3b3b3b3b3b393010505010105020501020102010201020105050205010105050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000093b3b3a0b3b3b39393b3b382b3b39193040505050502050501050505040505050105020505040105050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000093939393939393939393939393939393050505050505050501050505050505050101050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001807017070170701707018070180001800018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001d0701c0701c0701c0701d070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002e0702d0702b070290702707025070230701f0701c0701607012070110700c070040700107015000120000d0000100000000000000000000000000000000000000000000000000000000000000000000
010100000c6330e6320c6310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002d500325001350021500255002b50013500295002b5002f5003050015700117000b700137001b700147000f7000a700127001a700157001c7000e700067000a700147001b700177000f7000f70011700
000600000e42300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000087000a700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200201a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521a50223552235521a5021a5021a5021a5021a5021a5021a502175021a5021a5021a5021a5021a5021a5020050223502
0112002004054040040405404004060540e003040540c0030705406054040540c0030805413003070541100304004040040405404004060540e003040540c0030705406054040540c00308054130030705411003
01120020046250460504625046050460504605046251b60504605046050460504605046251e605046051a605046250460504625046050460504605046251b60504605046050460504605046251e605046051a605
011200201a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521a5521d5021d5521d5021c5521c5521c5021c502000000000000000000000000000000000000000000000000000000000000
010a0000180551d035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001d055180551704512045110350c0350b02506025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001d055180551704512045110350c0350b02506025030450204501035000350002500025000150001500000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000033500535006350083500b3500d350103501650016300193001c3001f3002030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000a5500d55010550155501b55020550255502a5502a5002a5002a50032500285002c5002f5003450039500000000000000000000000000000000000000000000000000000000000000000000000000000
00100000097500a7500c7500d7500a7500c7500f750147500a7500c7500f750157500f75013750187501e75014750177501b7501f750177501a7501c750217501a7501e750257502875038750397503975039750
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800200c0351004515055170550c0351004515055170550c0351004513055180550c0351004513055180550c0351104513055150550c0351104513055150550c0351104513055150550c035110451305515055
003000202874028740287302872026740267301c7401c7301d7401d7401d7401d7401d7301d7301d7201d72023740237402373023720267402674026730267201c7401c7401c7401c7401c7301c7301c7201c720
0030002000040000400003000030020400203004040040300504005040050300503005020050200502005020070400704007030070300b0400b0400b0300b0300c0400c0400c0300c0300c0200c0200c0200c020
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
00100011116500c25016550116500b25017550106500c25006450186502a630084502a650094000b6000d2000a4000e2000000000000000000000000000000000000000000000000000000000000000000000000
00100011000000b650000002c65025650036500000006650000000000006650000000000006650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000e073000002420500000376353760537600326000e073000000e07300000376350000024205000050e07300000000000000037635000002b6050e0430e0730e0030e0730e00337635000003760537635
011000000c470004710c4700000007400074710a4700a4000f470114700f4700e4700a4210a4410a4710a4700c470004710c47000000000000f470114000000011470124710000011470000000f470000000a470
011000000c470004710c4700000007400074700a4700a4000c4700f4710f43113470134001647016475164050c470004710c4700c4000c4000f400164701640013470114710f4700f4000f470114710a4700a400
011000200c1750010500175001050017507175001050a175001750010500175001050017507175001050a175001750010500175001050017507175001050a1750a175164750a17516465001050a175164650a175
00020000000000c06010070170701b0701d07023070280702c0702c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000010351153511935119351153510f351184011740113401114010b4011040113401174011940119401184011740113401114010b4011040101500015000150001500015000150005500000000000000000
00080000326502b650266501e6502c650346502e6502a6501e65020650276502c6502060022600226002260022600226002260022600213000000000000000000000000000000000000000000000000000000000
00060000331502e1502b15026150221501f1501a1501715013150101500d150091500715003150011500000000000000002200000000000000000000000000000000000000000000000000000000000000000000
010800200c653001713c6250000030650246113c6253c6050c653001713c6253c62530650246113c625000000c653001713c6250000030650246113c6253c6050c653001710c6530017130650246113c6253c625
011000000c4750c475134750c4750c4750c475134750c4750c4750c475134750c4750c4750c475134750c47508475084750f4750847508475084750f475084750a4750a475114750a4750a4750a475114750a475
0110000018270182701c2001c2001827018270162701827018270162701627018270182701a2701a2701b2001b2701b2701a2701a27018270182701627018270182701b2701b2701a2701a270002001627016270
011000000c2702427124370243702437224372243722437230271302703037030370303723037230372303722b2702b3722927029372222702437027270293702427027370292702b370272702b3702e37030370
0002000000000100400a0300502002010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000002205000000040502e05000000130500a050000001265000000000000000000000040500365000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000110500a0501803001000361001c000381003c1003f1001c000180001a0001c000180001a0001c000180001a0001c000180001a0021c002180001a0021c0020d00007000010000d00022000220001d000
00070000065500b55011530185301e520245202b51031510300003100031000310003100032000320003200032000320003200032000320003200032000320003200032000320003200032000320003200032000
000600000a75007750087500775006750057500775007750067500675004750047500575004750037500275002750037500375001750027500375001750017400273002720027200172001710017100170002700
00060000377503775037750067002e7502e7502e7500e7003c7503c7503c750110003f7503f7503f750390000000007000040002d000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000090500c050150501b0502d0502e0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a050220501a05015050110500b0500505003050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400200c4550c4550f4550c4550c623124550c4550f4550c4550c4550f4550c4550c623124550c4550f4550c4550c4550f4550c4550c623124550c4550f4550c4550c4550c6230c4550c6230c4550c4550c455
012800000c2540c2510c2540c2510f2540f2510f2440f2310c2540c2510c2540c251032540321103234032110c2540c2510c2540c2510f2540f2510f2440f2310c2540c2510f2540f2510c2440c2310c27400211
__music__
01 19404344
00 18424344
02 18424344
00 59424344
01 14555617
00 14555617
00 14151617
02 14151617
01 41094244
00 41090a44
00 08090a44
02 0b090a44
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
01 25555424
00 25552624
00 25272624
02 25272624
00 41424344
00 41424344
00 41424344
00 41424344
01 5d1f1d1c
00 4c1f1d1c
00 411f1e1c
02 411f1e1c
03 292a4344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41423e7f
03 41423e3f
00 41424344
00 41424344
