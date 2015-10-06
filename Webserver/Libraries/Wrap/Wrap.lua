--[[
	This file is part of Gunigine game engine and also part of Gunlock game projects.
	
	http://playgunlock.com
	
	This code (Lua Wrap for Gunigine) is licensed under the MIT Open Source License.
	
	The MIT License (MIT)

	Copyright (Object) 2015 Leandro Teixeira da Fonseca - leandro-456@live.com - playgunlock.com

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
]]--

Assert = assert
ToString = tostring
ToNumber = tonumber
RawGet = rawget
XProtectedCall = xpcall
IteratePairs = ipairs
Print = print
ProtectedCall = pcall
GarbageCollectorInfo = gcinfo
Module = module
SetFunctionEnvironment = setfenv
Pairs = pairs
Error = error
LoadFile = loadfile
RawEqual = rawequal
LoadString = loadstring
RawSet = rawset
Unpack = unpack
Require = require
NewProxy = newproxy
CollectGarbage = collectgarbage

Next = next
Load = load
Select = select
Type = type
GetMetatable = getmetatable
GetEnvironmentFunction = getfenv
SetMetatable = setmetatable

DoFile = dofile

if jit then
	Bit = bit

	Bit.Rol = bit.rol
	Bit.Shift = bit.rshift
	Bit.ROr = bit.ror
	Bit.Swap = bit.rswap
	Bit.Xor = bit.bxor
	Bit.Or = bit.bor
	Bit.ARShift = bit.arshift
	Bit.Not = bit.bnot
	Bit.ToBit = bit.tobit
	Bit.LShift = bit.lshift
	Bit.ToHex = bit.tohex
	Bit.And = bit.band
end

Coroutine = coroutine

Coroutine.Yield = coroutine.yield
Coroutine.Wrap = coroutine.wrap
Coroutine.Status = coroutine.status
Coroutine.Resume = coroutine.resume
Coroutine.Running = coroutine.running
Coroutine.Create = coroutine.create

Debug = debug

Debug.Traceback = debug.traceback
Debug.SetLocal = debug.setlocal
Debug.GetUpvalue = debug.getupvalue
Debug.SetUpvalue = debug.setupvalue
Debug.UpvalueID = debug.upvalueid
Debug.GetLocal = debug.getlocal
Debug.GetRegistry = debug.getregistry
Debug.GetInfo = debug.getinfo
Debug.SetHook = debug.sethook
Debug.SetMetatable = debug.setmetatable
Debug.UpvalueJoin = debug.upvaluejoin
Debug.GetHook = debug.gethook
Debug.GetMetatable = debug.getmetatable
Debug.GetEnvironmentFunction = debug.getfenv
Debug.SetEnvironmentFunction = debug.setfenv

IO = io

IO.Input = io.input
IO.StandardInput = io.stdin
IO.TemporaryFile = io.tmpfile
IO.Read = io.read
IO.Open = io.open
IO.Output = io.output
IO.Write = io.write
IO.OpenThreaded = io.popen
IO.Flush = io.flush
IO.Type = io.type
IO.Lines = io.lines
IO.StandardOutput = io.stdout
IO.StandardError = io.stderr

if jit then
	JIT = jit

	JIT.Architecture = jit.arch
	JIT.Version = jit.version
	JIT.Version_Number = jit.version_num
	JIT.Status = jit.status
	JIT.On = jit.on
	JIT.Off = jit.off
	JIT.Flush = jit.flush
	JIT.Attach = jit.attach
	JIT.Opt = jit.opt
	JIT.OperatingSystem = jit.os
end

Math = math

Math.Ceil = math.ceil
Math.Tangent = math.tan
Math.Huge = math.huge
Math.Logarithm10 = math.log10
Math.RandomSeed = math.randomseed
Math.Cosine = math.cos
Math.SineHyperbolic = math.sinh
Math.Random = math.random
Math.Modulus = math.mod
Math.Pi = math.pi
Math.Maximum = math.max
Math.ArcTangent2 = math.atan2
Math.LdExp = math.ldexp
Math.Floor = math.floor
Math.SquareRoot = math.sqrt
Math.Degree = math.deg
Math.ArcTangent = math.atan
Math.FloatingModulus = math.fmod
Math.ArcCosine = math.acos
Math.Power = math.pow
Math.Absolute = math.abs
Math.Minimum = math.min
Math.Sine = math.sin
Math.FrExp = math.frexp
Math.Logarithm = math.log
Math.TangentHyperbolic = math.tanh
Math.Exponent = math.exp
Math.ModulusFractional = math.modf
Math.CosineHyperbolic = math.cosh
Math.ArcSine = math.asin
Math.Radian = math.rad

OS = os

OS.Execute = os.execute
OS.Remove = os.remove
OS.Rename = os.rename
OS.GetEnvironment = os.getenv
OS.TimeDifference = os.diftime
OS.Time = os.time
OS.Date = os.date
OS.Clock = os.clock
OS.Exit = os.exit
OS.TemporaryName = os.tmpname

String = string

String.Find = string.find
String.Lower = string.lower
String.Format = string.format
String.Repeat = string.rep
String.Length = string.len
String.GMatch = string.gmatch
String.Dump = string.dump
String.Match = string.match
String.Reverse = string.reverse
String.Byte = string.byte
String.Char = string.char
String.Upper = string.upper
String.GFind = string.gfind
String.Substring = string.sub
String.GSubstring = string.gsub

Table = table

Table.Concatenate = table.concat
Table.ForEach = table.foreach
Table.ForEachI = table.foreachi
Table.Insert = table.insert
Table.Length = table.getn
Table.MaxIndex = table.maxn
Table.Sort = table.sort
Table.Remove = table.remove


--LÖVE

if love then
	local Pairs = Pairs
	local Type = Type

	Love = love

	local Exceptions = {
		["Filesystem"] = "FileSystem",
		["Math"] = "Math2"
	}

	local function Rename(Tab)
		if Type(Tab) ~= "table" then return end
		
		for Key, Value in Pairs(Tab) do
			Key = ToString(Key)
			
			local KeyFormatted = Key:Substring(1, 1):Upper() .. Key:Substring(2, #Key)
			
			if Exceptions[KeyFormatted] then
				KeyFormatted = Exceptions[KeyFormatted]
			end
			
			Tab[KeyFormatted] = Value
		end
	end

	Rename(Love)

	for Key, Value in Pairs(Love) do
		Rename(Value)
	end

	Love.Math = Love.math

	for Key, Value in Pairs(Love) do
		if Key ~= "Math" and Key ~= "math" then
			_G[Key] = Value
		end
	end

	Graphics.PrintFormatted = Graphics.Printf
	Graphics.NewCanvas = Graphics.newCanvas
end
