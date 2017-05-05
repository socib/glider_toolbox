function varargout = mexsftp(funcname, varargin)
%MEXSFTP  Mex interface to libssh for sftp connections.
%
%  Syntax:
%    H = MEXSFTP('create', HOST, PORT, USER, PASS)
%    MEXSFTP('delete', S)
%    MEXSFTP('connect', H, HOST, PORT, USER, PASS)
%    MEXSFTP('disconnect', H)
%    PATH = MEXSFTP('pwd', H)
%    MEXSFTP('cwd', H, PATH)
%    ATTS = MEXSFTP('lsfile', H, FILE)
%    ATTS = MEXSFTP('lsdir', H, DIRECTORY)
%    ATTS = MEXSFTP('lsglob', H, GLOB)
%    MEXSFTP('mkdir', H, PATH)
%    MEXSFTP('rmdir', H, PATH)
%    MEXSFTP('rename', H, SOURCE, TARGET)
%    MEXSFTP('delfile', H, PATH)
%    MEXSFTP('getfile', H, RPATH, LPATH)
%    MEXSFTP('putfile', H, LPATH, RPATH)
%
%  Description:
%    H = MEXSFTP('create', H, HOST, PORT, USER, PASS) creates a connection
%    to the server, initializing the ssh and sftp sessions and the working
%    directory, and returns a reference to the sftp connection.
%    If no port, user or password are given, the default values are used.
%
%    MEXSFTP('delete', H) closes a connection to the server, and deletes the 
%    referenced sftp connection, destroying the ssh and sftp sessions.
%
%    MEXSFTP('connect', H, HOST, PORT, USER, PASS) opens a connection to the
%    server using the internal reference to the already created sftp connection.
%    If no port, user or password are given, the default values are used.
%
%    MEXSFTP('disconnect', H) closes a connection to the server, but does not 
%    delete the referenced sftp connection.
%
%    PATH = MEXSFTP('pwd', H) returns the current working directory on the
%    server.
%
%    MEXSFTP('cwd', H, PATH) changes the current working directory on the
%    server.
%
%    ATTS = MEXSFTP('lsfile', H, FILE) returns the attributes of a file on the
%    server in a scalar struct with the following fields:
%      NAME: string with the file name (without leading directory path).
%      BYTES: double with the file size in bytes.
%      ISDIR: logical whether the file is a directory.
%      DATE: array with the modification time as a date vector.
%
%    ATTS = MEXSFTP('lsdir', H, DIRECTORY) returns the attributes of all
%    entries in a directory on the server in a struct array with the fields
%    described above.
%
%    ATTS = MEXSFTP('lsglob', H, GLOB) returns the attributes of all files on
%    the server whose name matches a glob in a struct array with the fields
%    described above. Wildcards are only allowed in the file name, not in the 
%    leading directory path. If no file matches the glob, the result is empty.
%
%    MEXSFTP('mkdir', H, PATH) creates a new directory on the server.
%    Parent directories should exist.
%
%    MEXSFTP('rmdir', H, PATH) deletes a directory from the server.
%    Directory should be empty.
%
%    MEXSFTP('rename', H, SOURCE, TARGET) renames or moves a file on the server.
%    Parent directories of new path should exist.
%
%    MEXSFTP('delfile', H, PATH) deletes a file on the server.
%    File can not be a directory, use 'rmdir' instead.
%
%    MEXSFTP('getfile', H, RPATH, LPATH) downloads the file from the remote path
%    on the server to the local path. Local path is the full name of the target,
%    and leading directories should exist. Remote path must not be a directory.
%
%    MEXSFTP('putfile', H, LPATH, RPATH) uploads a file from the local path to
%    the remote path on the server. Remote path is the full name of the target
%    and leading directories should exist. Local path must not be a directory.
%
%  Notes:
%    This function provides an interface to perform operations through an SFTP
%    connection to a remote server using the API provided by the library libssh.
%    All low level operations are implemented in the companion mex file.
%
%    This function is not intended to be called directly by the user,
%    but to implement methods of the SFTP objects. Use methods of SFTP instead.
%
%  References:
%    Aris Adamantiadis and Andreas Schneider, libssh library:
%    <http://www.libssh.org/>
%
%  See also:
%    SFTP
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2014-2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears
%  <http://www.socib.es>
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  error('sftp:mexsftp:MissingMexFile', 'Missing required mex file');
  
end
