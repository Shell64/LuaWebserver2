--[[
	This file is part of Gunigine game engine and also part of Gunlock game projects.
	
	http://playgunlock.com
	
	This code (FileSystem2 for Gunigine) is licensed under the MIT Open Source License.
	
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


local FileSystem2 = {}

local IO = IO
local LFS = Require("lfs")

local ToString = ToString

function FileSystem2.Append(Path, Data)
	if FileSystem2.IsFile(Path) then
		local File, Err = IO.Open(Path, "a+")
		
		if not File then
			return nil, Err
		end
		
		File:seek("end")
		File:write(ToString(Data))
		File:close()
		
		return true
	else
		local File, Err = IO.Open(Path, "w")
		
		if not File then
			return nil, Err
		end
		
		File:write(ToString(Data))
		File:close()
		
		return true
	end
end

function FileSystem2.GetSize(Path)
	local Attributes, Err = LFS.attributes(Path)
	
	if Attributes and Attributes.mode == "file" then
		return Attributes.size
	else
		return nil, Err
	end
end

function FileSystem2.CreateDirectory(Path)
	if not FileSystem2.IsDirectory(Path) then
		return LFS.mkdir(Path)
	end
end

function FileSystem2.CreateDirectory(Path)
	return LFS.mkdir(Path)
end

function FileSystem2.IsFile(Path)
	local Attributes, Err = LFS.attributes(Path)
	
	if Attributes and Attributes.mode == "file" then
		return true
	else
		return false, Err
	end
end

function FileSystem2.IsDirectory(Path)
	local Attributes, Err = LFS.attributes(Path)
	
	if Attributes and Attributes.mode == "directory" then
		return true
	else
		return false, Err
	end
end

function FileSystem2.IsSymlink(Path)
	local Attributes, Err = LFS.attributes(Path)
	
	if Attributes and Attributes.mode == "link" then
		return true
	else
		return false, Err
	end
end

function FileSystem2.Load(Path)
	if FileSystem2.IsFile(Path) then
		return LoadString(FileSystem2.Read(Path))
	end
end

function FileSystem2.NewFileMode(Path, Mode)
	return IO.Open(Path, Mode)
end

function FileSystem2.NewFile(Path)
	return IO.Open(Path)
end

function FileSystem2.Read(Path)
	local File, Err = IO.Open(Path, "rb")
		
	if not File then
		return nil, Err
	end
	
	local Data = File:read("*all")
	File:close()
	
	return Data
end

function FileSystem2.Remove(Path)
	return OS.Remove(Path)
end

function FileSystem2.Write(Path, Data)
	local File, Err = IO.Open(Path, "w")
	
	if not File then
		return nil, Err
	end
	
	File:write(ToString(Data))
	File:close()
	
	return true
end

function FileSystem2.Attributes(Path)
	return LFS.attributes(Path)
end

return FileSystem2