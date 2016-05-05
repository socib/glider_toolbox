/**
 * @file
 * @brief Mex interface to libssh for sftp connection.
 * @author Joan Pau Beltran  <joanpau.beltran@socib.cat>
 *
 *  Copyright (C) 2014-2016
 *  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
 *  <http://www.socib.es>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * This file implements an interface to perform operations through an SFTP 
 * connection to a remote server using the API provided by the library libssh.
 *
 * The libssh library provides a client API for the SFTP protocol. 
 * The official web site of the library is:
 *   <https://www.libssh.org/>
 * 
 * On Debian based systems, the package libssh-dev in the official
 * repositories provides the development files for the libssh library.
 * The mex file may be built with the command:
 *   mex -lssh mexsftp.c
 *
 * Alternatively, it is possible to build the mex file using precompiled 
 * versions of the library for other platforms available at the web site,
 * or a version of the library compiled from sources locally.
 * If the header files and the binary files are located in the 
 * respective directories 'libssh/include/libssh' and 'libssh/lib/',
 * the mex file may be built with the command:
 *   mex -Ilibssh/include -Llibssh/lib -lssh mexsftp.c
 * In that case, the run-time library path should include the directory 
 * containing the shared library file. On GNU/Linux systems this can be avoided
 * if the path to the dynamic library is included during the linkage:
 *   mex -Ilibssh/include -Llibssh/lib -Wl,-rpath=/path/to/libssh/lib -lssh mexsftp.c
 *
 * Notes:
 *   The implementation trick here is to store the ssh and sftp sessions in a
 *   structure referenced by a pointer, and pass that pointer into and out of
 *   the funtions in the mex interface. Thus, the pointer, casted to unsigned
 *   integer, acts as a handle to the sftp connection.
 *   Also note that the SFTP protocol does not define the notion of remote
 *   working directory. So the sftp connection also stores the remote working 
 *   directory given when creating the connection, updates it upon a change of
 *   directory, and prepends it to any relative path passed to the functions.
 */


#include "mex.h"
#include "libssh/libssh.h"
#include "libssh/sftp.h"
#include <stddef.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>


static char * prepend_pwd(const char *path, const char *pwd)
{
  char *full;
  size_t m, n;
  if (! path) {
    full = NULL;
  } else if (! pwd) {
    full = strdup(path);
  } else {
    m = strlen(pwd);
    n = strlen(path);
    full = malloc(m + n + 2);
    if (full) {
      strncpy(full, pwd, m + 1);
      if ( m > 0 && pwd[m-1] != '/')
        strncat(full, "/", 2);
      strncat(full, path, n + 1);
    }
  }
  return full;
}

static char * expand_path(const char *path, const char *pwd)
{
  char * full;
  full = (path && path[0] == '/') ? strdup(path) : prepend_pwd(path, pwd);
  return full;
}

static int exclude_directory_entry(const char* name)
{
  int exclude;
  if (! name)
    exclude = 0;
  else
    exclude = (name[0] == '.');
  return exclude;
}

static int glob_match(const char* glob, const char* str)
{
  int match;
  if (*glob == '\0')
    match = (*str == '\0');
  else if (*glob == '*')
    do
      match = glob_match(glob + 1, str);
    while (*str++ && ! match);
  else if (*glob == '?' && *str)
    match = glob_match(glob + 1, str + 1);
  else if (*glob == *str)
    match = glob_match(glob + 1, str + 1);
  else  
    match = 0;
  return match;
}

static int glob_name_match(const char* glob, const char* name)
{
  int match;
  if (! (glob && name))
    match = 0;
  else if (*glob == '*' && *name == '.')
    match = 0;
  else if (*glob == '?' && *name == '.')
    match = 0;
  else
    match = glob_match(glob, name);
  return match;
}


typedef struct sftp_attributes_list_struct {
  sftp_attributes atts;
  struct sftp_attributes_list_struct *next;
  struct sftp_attributes_list_struct *prev;
} sftp_attributes_list_struct;

typedef struct sftp_attributes_list_struct *sftp_attributes_list;

static sftp_attributes_list
addhead_sftp_attributes_list(sftp_attributes_list list, sftp_attributes atts)
{
  sftp_attributes_list head, iter;
  head = list->next;
  iter = malloc(sizeof *iter);
  if (iter) {
    iter->atts = atts;
    list->next = iter;
    iter->prev = list;
    iter->next = head;
    head->prev = iter;
  }
  return iter;
}

static sftp_attributes_list
addtail_sftp_attributes_list(sftp_attributes_list list, sftp_attributes atts)
{
  sftp_attributes_list tail, iter;
  tail = list->prev;
  iter = malloc(sizeof *iter);
  if (iter) {
    iter->atts = atts;
    tail->next = iter;
    iter->prev = tail;
    iter->next = list;
    list->prev = iter;
  }
  return iter;
}

static sftp_attributes
remhead_sftp_attributes_list(sftp_attributes_list list)
{
  sftp_attributes atts;
  sftp_attributes_list head;
  atts = NULL;
  head = list->next;
  if (head != list) {
    atts = head->atts;
    head->prev->next = head->next;
    head->next->prev = head->prev;
    free(head);
  }
  return atts;
}

static sftp_attributes
remtail_sftp_attributes_list(sftp_attributes_list list)
{
  sftp_attributes atts;
  sftp_attributes_list tail;
  atts = NULL;
  tail = list->prev;
  if (tail != list) {
    atts = tail->atts;
    tail->prev->next = tail->next;
    tail->next->prev = tail->prev;
    free(tail);
  }
  return atts;
}

static size_t
length_sftp_attributes_list(sftp_attributes_list list)
{
  size_t n;
  sftp_attributes_list iter;
  for (n = 0, iter = list->next; iter != list; n++, iter = iter->next) ;
  return n;
}

static sftp_attributes_list make_sftp_attributes_list(void)
{
  sftp_attributes_list list;
  list = malloc(sizeof *list);
  if (list) {
    list->atts = NULL;
    list->prev = list;
    list->next = list;
  }
  return list;
}

static void free_sftp_attributes_list(sftp_attributes_list list)
{
  sftp_attributes_list iter, next;
  if (list) {
    for (iter = list->next; iter != list; iter = next) {
      next = iter->next;
      sftp_attributes_free(iter->atts);
      free(iter);
    }
    free(list);
  }
}

static sftp_attributes_list head_sftp_attributes_list(sftp_attributes_list list)
{
  return list->next;
}

static sftp_attributes_list tail_sftp_attributes_list(sftp_attributes_list list)
{
  return list->prev;
}

static sftp_attributes_list lend_sftp_attributes_list(sftp_attributes_list list)
{
  return list;
}

static sftp_attributes_list prev_sftp_attributes_list(sftp_attributes_list iter)
{
  return iter->prev;
}

static sftp_attributes_list next_sftp_attributes_list(sftp_attributes_list iter)
{
  return iter->next;
}

static sftp_attributes atts_sftp_attributes_list(sftp_attributes_list iter)
{
  return iter->atts;
}


typedef struct sftp_connection_struct {
  ssh_session ssh;
  sftp_session sftp;
  char* pwd;
} sftp_connection_struct;

typedef sftp_connection_struct *sftp_connection;

static sftp_connection make_sftp_connection(void)
{
  sftp_connection conn;
  conn = malloc(sizeof *conn);
  if (conn) {
    conn->ssh = NULL;
    conn->sftp = NULL;
    conn->pwd = NULL;
  }
  return conn;
}

static void free_sftp_connection(sftp_connection conn)
{
  free(conn);
}

static const char * sftp_get_error_msg (sftp_session sftp) {
  switch (sftp_get_error(sftp)) {
    case SSH_FX_OK:
      return "No error";
    case SSH_FX_EOF:
      return "Unexpected end-of-file";
    case SSH_FX_NO_SUCH_FILE:
      return "File doesn't exist";
    case SSH_FX_PERMISSION_DENIED:
      return "Permission denied";
    case SSH_FX_FAILURE:
      return "Generic failure";
    case SSH_FX_BAD_MESSAGE:
      return "Garbage received from server";
    case SSH_FX_NO_CONNECTION:
      return "No connection set up";
    case SSH_FX_CONNECTION_LOST:
      return "Connection lost";
    case SSH_FX_OP_UNSUPPORTED:
      return "Operation not supported";
    case SSH_FX_INVALID_HANDLE:
      return "Invalid file handle";
    case SSH_FX_NO_SUCH_PATH:
      return "No such file or directory";
    case SSH_FX_FILE_ALREADY_EXISTS:
      return "File already exists";
    case SSH_FX_WRITE_PROTECT:
      return "Write-protected filesystem";
    case SSH_FX_NO_MEDIA:
      return "No media in remote drive";
  }
}

static void open_sftp_connection(int *rc, const char* *message,
                                 sftp_connection conn, 
                                 const char *host, const unsigned int *port, 
                                 const char *user, const char *pass)
{
  ssh_session ssh;
  sftp_session sftp;
  char* pwd;
  
  /* Create ssh session object. */
  ssh = ssh_new();
  if (ssh == NULL) {
    *message = "Could no create new ssh session.";
    *rc = SSH_ERROR;
    return;
  }
  
  /* Set host, port and user options. */
  ssh_options_set(ssh, SSH_OPTIONS_HOST, host);
  if (port) {
    ssh_options_set(ssh, SSH_OPTIONS_USER, port);
  }
  if (user) {
    ssh_options_set(ssh, SSH_OPTIONS_USER, user);
  }
  
  /* Connect to the remote host. */
  *rc = ssh_connect(ssh);
  if (*rc != SSH_OK) {
    *message = ssh_get_error(ssh);
    return;
  }
  
  /* Check host is known. */
  switch (ssh_is_server_known(ssh)) {
    case SSH_SERVER_KNOWN_OK:
      break;
    case SSH_SERVER_KNOWN_CHANGED:
      *message = "Server host key changed";
      *rc = SSH_ERROR;
      break;
    case SSH_SERVER_FOUND_OTHER:
      *message = "Server host key not found but other type of key exists";
      *rc = SSH_ERROR;
      break;
    case SSH_SERVER_FILE_NOT_FOUND:
      *message = "Known hosts file not found";
      *rc = SSH_ERROR;
      break;
    case SSH_SERVER_NOT_KNOWN:
      *message = "Unknow host server";
      *rc = SSH_ERROR;
      break;
    case SSH_SERVER_ERROR:
      *message = ssh_get_error(ssh);
      *rc = SSH_ERROR;
      break;
  }
  if (*rc != SSH_OK) {
    ssh_disconnect(ssh);
    ssh_free(ssh);
    return;
  }
  
  /* Authenticate. */
  if (pass) {
    *rc = ssh_userauth_password(ssh, NULL, pass);
  } else {
    /* *rc = ssh_userauth_publickey_auto(ssh, NULL); */
    *rc = ssh_userauth_autopubkey(ssh, NULL);
  }
  switch (*rc) {
    case SSH_AUTH_SUCCESS:
      break;
    case SSH_AUTH_ERROR:
      *message = ssh_get_error(ssh);
      break;
    case SSH_AUTH_DENIED:
      *message = "Permission denied";
      break;
    default:
      *message = "Authentication not complete";
  }
  if (*rc != SSH_AUTH_SUCCESS) {
    ssh_disconnect(ssh);
    ssh_free(ssh);
    return;
  }
  
  /* Create sftp session object. */
  sftp = sftp_new(ssh);
  if (sftp == NULL) {
    *message = "Could no create new sftp session";
    *rc = SSH_ERROR;
    ssh_disconnect(ssh);
    ssh_free(ssh);
    return;
  }
  
  /* Init sftp session. */
  *rc = sftp_init(sftp);
  if (*rc != SSH_OK)
  {
    *message = sftp_get_error_msg(sftp);
    sftp_free(sftp);
    ssh_disconnect(ssh);
    ssh_free(ssh);
    return;
  }
  
  /* Get remote working directory. */
  pwd = sftp_canonicalize_path(sftp, ".");
  if (! pwd) {
    *message = "Could not get current working directory.";
    *rc = ssh_get_error_code(ssh);
    sftp_free(sftp);
    ssh_disconnect(ssh);
    ssh_free(ssh);
    return;
  }
  
  /* Check the connection handle. */
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_ERROR;
    free(pwd);
    sftp_free(sftp);
    ssh_disconnect(ssh);
    ssh_free(ssh);
    return;
  }

  /* Populate the connection members. */
  conn->ssh = ssh;
  conn->sftp = sftp;
  conn->pwd = pwd;
}


static void close_sftp_connection(sftp_connection conn)
{
  if (conn) {
    if (conn->pwd) {
      free(conn->pwd);
      conn->pwd = NULL;
    }
    if (conn->sftp) {
      sftp_free(conn->sftp);
      conn->sftp = NULL;
    }
    if (conn->ssh) {
      ssh_disconnect(conn->ssh);
      ssh_free(conn->ssh);
      conn->ssh = NULL;
    }
  }
}


static void cwd_sftp_connection(int *rc, const char* *message, 
                                sftp_connection conn, const char* path)
{
  ssh_session ssh;
  sftp_session sftp;
  sftp_attributes atts;
  char *pwd, *nwd, *cwd;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  nwd = expand_path(path, pwd);
  if (! nwd) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  cwd = sftp_canonicalize_path(sftp, nwd);
  if (! cwd) {
    *message = "Could not get new working directory";
    *rc = ssh_get_error_code(ssh);
    free(nwd);
    return;
  }
  atts = sftp_stat(sftp, cwd);
  if (! atts) {
    *message = "Could not check new working directory";
    *rc = ssh_get_error_code(ssh);
    free(cwd);
    free(nwd);
    return;
  }
  if (atts->type != SSH_FILEXFER_TYPE_DIRECTORY) {
    *message = "Not a directory";
    *rc = SSH_ERROR;
    free(atts);
    free(cwd);
    free(nwd);
    return;
  }
  conn->pwd = cwd;
  *rc = SSH_OK;
  free(pwd);
  free(nwd);
  free(atts);
}


static bool isdir_sftp_attributes(sftp_attributes atts)
{
  return atts && atts->type == SSH_FILEXFER_TYPE_DIRECTORY;
}

static void
lsfile_sftp_connection(int *rc, const char* *message, sftp_attributes *atts,
                       sftp_connection conn, const char* path)
{
  sftp_attributes stat;
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *epath;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  epath = expand_path(path, pwd);
  if (! epath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  stat = sftp_stat(sftp, epath);
  if (! stat) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    free(epath);
    return;
  }
  if (! stat->name)
    stat->name = ssh_basename(epath);
  if (! stat->name) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    sftp_attributes_free(stat);
    free(epath);
    return;
  }
  *atts = stat;
  *rc = SSH_OK;
  free(epath);
}


static void
lsdir_sftp_connection(int *rc, const char* *message, sftp_attributes_list *list,
                      sftp_connection conn, const char* path)
{
  sftp_attributes_list atts_list;
  sftp_attributes atts;
  sftp_dir dir;
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *epath;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  epath = expand_path(path, pwd);
  if (! epath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  dir = sftp_opendir(sftp, epath);
  if (! dir) {
    *rc = sftp_get_error(sftp);
    *message = sftp_get_error_msg(sftp);
    free(epath);
    return;
  }
  atts_list = make_sftp_attributes_list();
  if (! atts_list) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    sftp_closedir(dir);
    free(epath);
    return;
  }
  while ((atts = sftp_readdir(sftp, dir))
         && (exclude_directory_entry(atts->name) 
             || addtail_sftp_attributes_list(atts_list, atts)))
  {}
  if (atts) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    sftp_attributes_free(atts);
    free_sftp_attributes_list(atts_list);
    sftp_closedir(dir);
    free(epath);
    return;
  } else if (! sftp_dir_eof(dir)) {
    *rc = sftp_get_error(sftp);
    *message = sftp_get_error_msg(sftp);
    free_sftp_attributes_list(atts_list);
    sftp_closedir(dir);
    free(epath);
    return;
  }
  *rc = sftp_closedir(dir);
  if (*rc != SSH_OK) {
    *rc = sftp_get_error(sftp);
    *message = sftp_get_error_msg(sftp);
    free_sftp_attributes_list(atts_list);
    free(epath);
    return;
  }
  *list = atts_list;
  free(epath);
}


static void
lsglob_sftp_connection(int *rc, const char* *message, sftp_attributes_list *list,
                       sftp_connection conn, const char* glob)
{
  sftp_attributes_list atts_list;
  sftp_attributes atts;
  sftp_dir dir;
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *eglob, *epath, *pattern;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  eglob = expand_path(glob, pwd);
  if (! eglob) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  epath = ssh_dirname(eglob);
  if (! epath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    free(eglob);
    return;
  }
  pattern = ssh_basename(eglob);
  if (! pattern) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    free(epath);
    free(eglob);
    return;
  }
  dir = sftp_opendir(sftp, epath);
  if (! dir) {
    *rc = sftp_get_error(sftp);
    *message = sftp_get_error_msg(sftp);
    free(pattern);
    free(epath);
    free(eglob);
    return;
  }
  atts_list = make_sftp_attributes_list();
  if (! atts_list) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    sftp_closedir(dir);
    free(pattern);
    free(epath);
    free(eglob);
    return;
  }
  while ((atts = sftp_readdir(sftp, dir))
         && ((! glob_name_match(pattern, atts->name))
             || addtail_sftp_attributes_list(atts_list, atts)))
  {}
  if (atts) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    sftp_attributes_free(atts);
    free_sftp_attributes_list(atts_list);
    sftp_closedir(dir);
    free(pattern);
    free(epath);
    free(eglob);
    return;
  } else if (! sftp_dir_eof(dir)) {
    *rc = sftp_get_error(sftp);
    *message = sftp_get_error_msg(sftp);
    free_sftp_attributes_list(atts_list);
    sftp_closedir(dir);
    free(pattern);
    free(epath);
    free(eglob);
    return;
  }
  *rc = sftp_closedir(dir);
  if (*rc != SSH_OK) {
    *rc = sftp_get_error(sftp);
    *message = sftp_get_error_msg(sftp);
    free_sftp_attributes_list(atts_list);
    free(pattern);
    free(epath);
    free(eglob);
    return;
  }
  *list = atts_list;
  free(pattern);
  free(epath);
  free(eglob);
}


static void
mkdir_sftp_connection(int *rc, const char* *message,
                      sftp_connection conn, const char* path)
{
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *epath;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  epath = expand_path(path, pwd);
  if (! epath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  *rc = sftp_mkdir(sftp, epath, S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
  if (*rc != SSH_OK) {
    *rc = sftp_get_error(sftp);
    if (*rc == SSH_FX_FILE_ALREADY_EXISTS) 
      *rc = SSH_OK;
  }
  if (*rc != SSH_OK) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    free(epath);
    return;
  }
  free(epath);
}


static void
rmdir_sftp_connection(int *rc, const char* *message,
                      sftp_connection conn, const char* path)
{
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *epath;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  epath = expand_path(path, pwd);
  if (! epath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  *rc = sftp_rmdir(sftp, epath);
  if (*rc != SSH_OK) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    free(epath);
    return;
  }
  free(epath);
}


static void
rename_sftp_connection(int *rc, const char* *message, sftp_connection conn, 
                       const char* opath, const char* npath)
{
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *eopath, *enpath;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  eopath = expand_path(opath, pwd);
  enpath = expand_path(npath, pwd);
  if (! (eopath && enpath)) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    free(eopath);
    free(enpath);
    return;
  }
  *rc = sftp_rename(sftp, eopath, enpath);
  if (*rc != SSH_OK) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    free(eopath);
    free(enpath);
    return;
  }
  free(eopath);
  free(enpath);
}


static void
delfile_sftp_connection(int *rc, const char* *message,
                        sftp_connection conn, const char* path)
{
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *epath;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  epath = expand_path(path, pwd);
  if (! epath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  *rc = sftp_unlink(sftp, epath);
  if (*rc != SSH_OK) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    free(epath);
    return;
  }
  free(epath);
}

static void
getfile_sftp_connection(int *rc, const char* *message, sftp_connection conn,
                        const char* rpath, const char* lpath)
{
  FILE *lfile;
  sftp_file rfile;
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *erpath;
  int blen, rlen;
  int reof, rerr, werr;
  int nreq, nbad, ireq;
  int reqs[32] = {0};
  int rsps[32] = {0};
  int lens[32] = {0};
  uint64_t offs[32] = {0};
  uint64_t tell, size;
  char buff[524288];
  const unsigned int max_nreq = sizeof(reqs) / sizeof(reqs[0]);
  const unsigned int max_blen = sizeof(buff);
  const unsigned int min_blen = 512;
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  erpath = expand_path(rpath, pwd);
  if (! erpath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  rfile = sftp_open(sftp, erpath, O_RDONLY, 0);
  if (! rfile) {
    *message = sftp_get_error_msg(sftp);
    *rc = SSH_ERROR;
    free(erpath);
    return;
  }
  lfile = fopen(lpath, "wb");
  if (! lfile) {
    *message = strerror(errno);
    *rc = SSH_ERROR;
    sftp_close(rfile);
    free(erpath);
    return;
  }
  /* Read the file in chuncks.
   * To read the file synchronously chunk by chunk is slow. Instead:
   *   - Request read operations without waiting the server response.
   *   - Write the respones to the local file when they are ready.
   * Servers may respond with less data than requested.
   * In that case send a new read request for the missing data.
   * The following scheme implements a queue of read requests defined by 
   * the identifier, the file offset, the length and the response.
   *   - If the length is zero, the request is complete.
   *   - Otherwise if the identifier is negative, it is unsent.
   *   - Otherwise if the response is SSH_AGAIN, it waits for the response.
   *   - Otherwise the request is incomplete (response shorter than request).
   * In the first loop, resend incomplete and unsent requests
   * and send new requests until end of file and no more pending requests.
   * In the second loop, process the requests: check for the response, 
   * and write the data to the local file, update the request's offset and 
   * length (make it complete or incomplete), and detect the end of file.
   * The number of read requests and the length of the requests are adjusted 
   * dynamically. 
   */
  for (blen = max_blen, nreq = 1, reof = 0, rerr = 0, werr = 0, nbad = 0, rlen = 0;
       (nreq > nbad) && (! rerr) && (! werr);
       nreq += (nbad > 0 || reof || nreq >= max_nreq) ? 0 : 1,
       blen /= (0 < rlen && rlen < blen && blen > min_blen) ? 2 : 1) {
    for (ireq = nreq - 1; (ireq >= 0) && (! rerr); ireq--) {
      if (reqs[ireq] < 0 || rsps[ireq] != SSH_AGAIN) {
        if (lens[ireq]) {
          rsps[ireq] = SSH_AGAIN;
          tell = sftp_tell64(rfile);
          rerr = (sftp_seek(rfile, offs[ireq]) < 0);
          if (! rerr) {
            nbad -= (reqs[ireq] < 0) ? 1 : 0;
            reqs[ireq] = sftp_async_read_begin(rfile, lens[ireq]);
            nbad += (reqs[ireq] < 0) ? 1 : 0;
            rerr = (sftp_seek64(rfile, tell) < 0);
          }
        } else if (reof || nbad) {
          nreq--;
          rsps[ireq] = rsps[nreq];
          lens[ireq] = lens[nreq];
          offs[ireq] = offs[nreq];
          reqs[ireq] = reqs[nreq];
        } else {
          rsps[ireq] = SSH_AGAIN;
          lens[ireq] = blen;
          offs[ireq] = sftp_tell64(rfile);
          reqs[ireq] = sftp_async_read_begin(rfile, lens[ireq]);
          nbad += (reqs[ireq] < 0) ? 1 : 0;
        }
      }
    }
    for (ireq = nreq - 1; (ireq >= 0) && (! rerr) && (! werr); ireq--) {
      if (reqs[ireq] >= 0) {
        /* The tell-seek-read-seek sequence should not be needed here.
         * Its purpose is to revert some buggy handling of the eof and offset 
         * fields in sftp_async_read.
         */
        tell = sftp_tell64(rfile);
        rerr = (sftp_seek64(rfile, offs[ireq]) < 0);
        if (! rerr) {
          rsps[ireq] = sftp_async_read(rfile, buff, lens[ireq], reqs[ireq]);
          rerr = (sftp_seek64(rfile, tell) < 0);
          if (rsps[ireq] > 0) {
            werr = fseek(lfile, offs[ireq], SEEK_SET) < 0;
            werr = werr || fwrite(buff, 1, rsps[ireq], lfile) - rsps[ireq];
            werr = werr || fseek(lfile, 0, SEEK_END) < 0;
            rlen = (rlen < rsps[ireq] && rsps[ireq] < blen && blen <= lens[ireq]) ? rsps[ireq] : rlen;
            offs[ireq] += rsps[ireq];
            lens[ireq] -= rsps[ireq];
          } else if (rsps[ireq] == 0) {
            lens[ireq] = 0;
            reof = 1;
          } else if (rsps[ireq] != SSH_AGAIN) {
            rerr = 1;
          }
        }
      }
    }
  }
  if (werr) {
    *message = strerror(errno);
    *rc = SSH_ERROR;
    sftp_close(rfile);
    fclose(lfile);
    free(erpath);
    return;
  }
  if (rerr) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    sftp_close(rfile);
    fclose(lfile);
    free(erpath);
    return;
  }
  if (nbad > 0) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    sftp_close(rfile);
    fclose(lfile);
    free(erpath);
    return;
  }
  *rc = fclose(lfile);
  if (*rc != 0) {
    *message = strerror(errno);
    *rc = SSH_ERROR;
    sftp_close(rfile);
    free(erpath);
    return;
  }
  *rc = sftp_close(rfile);
  if (*rc != SSH_OK) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    free(erpath);
    return;
  }
  free(erpath);
}


static void
putfile_sftp_connection(int *rc, const char* *message, sftp_connection conn,
                        const char* lpath, const char* rpath)
{
  struct stat atts;
  FILE *lfile;
  sftp_file rfile;
  ssh_session ssh;
  sftp_session sftp;
  char *pwd, *erpath;
  int rlen, wlen;
  int rerr, werr;
  char buff[65536];
  const unsigned int blen = sizeof(buff);
  if (! conn) {
    *message = "Invalid sftp connection handle";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  ssh = conn->ssh;
  sftp = conn->sftp;
  pwd = conn->pwd;
  if (! sftp) {
    *message = "Not open sftp connection";
    *rc = SSH_FX_NO_CONNECTION;
    return;
  }
  erpath = expand_path(rpath, pwd);
  if (! erpath) {
    *message = "Memory error";
    *rc = SSH_ERROR;
    return;
  }
  if (stat(lpath, &atts) < 0) {
    *message = strerror(errno);
    *rc = SSH_ERROR;
    free(erpath);
    return;
  }
  lfile = fopen(lpath, "rb");
  if (! lfile) {
    *message = strerror(errno);
    *rc = SSH_ERROR;
    free(erpath);
    return;
  }
  rfile = sftp_open(sftp, erpath,
                    O_WRONLY | O_CREAT | O_TRUNC,
                    atts.st_mode & (S_IRWXU | S_IRWXG | S_IRWXO));
  if (! rfile) {
    *message = ssh_get_error(ssh);
    *rc = SSH_ERROR;
    fclose(lfile);
    free(erpath);
    return;
  }
  /* Write the file in chuncks. 
   * libssh does not support asynchronous write operations.
   * Write the file synchronously chunk by chunk.
   */
  for (rlen = fread(buff, 1, blen, lfile), rerr = (rlen < 0), werr = 0;
       (! rerr) && (! werr) && (rlen > 0);
       rlen = fread(buff, 1, blen, lfile), rerr = (rlen < 0)) {
    werr = sftp_write(rfile, buff, rlen) - rlen;
  }
  if (rerr) {
    *message = strerror(errno);
    *rc = SSH_ERROR;
    sftp_close(rfile);
    fclose(lfile);
    free(erpath);
    return;
  }
  if (werr) {
    *message = ssh_get_error(ssh);
    *rc = SSH_ERROR;
    sftp_close(rfile);
    fclose(lfile);
    free(erpath);
    return;
  }
  *rc = sftp_close(rfile);
  if (*rc != SSH_OK) {
    *message = sftp_get_error_msg(sftp);
    *rc = sftp_get_error(sftp);
    fclose(lfile);
    free(erpath);
    return;
  }
  *rc = fclose(lfile);
  if (*rc != 0) {
    *message = strerror(errno);
    *rc = SSH_ERROR;
    free(erpath);
    return;
  }
  free(erpath);
}


void mexsftp_create( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *host, *user, *pass;
  unsigned int *port;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs!=1)
    mexErrMsgIdAndTxt("sftp:create:BadCall", "One output required.");
  switch (nrhs) {
    case 4:
      if (! ((mxIsChar(prhs[3]) && mxGetM(prhs[3]) == 1) ||
             (mxIsNumeric(prhs[3]) && mxGetNumberOfElements(prhs[3]) == 0)))
        mexErrMsgIdAndTxt("sftp:create:BadCall", "Password should be a string or empty.");
    case 3:
      if (! ((mxIsChar(prhs[2]) && mxGetM(prhs[2]) == 1) ||
             (mxIsNumeric(prhs[2]) && mxGetNumberOfElements(prhs[2]) == 0)))
        mexErrMsgIdAndTxt("sftp:create:BadCall", "User should be a string or empty.");
    case 2:
      if (! (mxIsNumeric(prhs[1]) && mxGetNumberOfElements(prhs[1]) < 2))
        mexErrMsgIdAndTxt("sftp:create:BadCall", "Port shoud be numeric scalar or empty.");
    case 1:
      if (! ((mxIsChar(prhs[0]) && mxGetM(prhs[0]) == 1) ||
             (mxIsNumeric(prhs[0]) && mxGetNumberOfElements(prhs[0]) == 0)))
        mexErrMsgIdAndTxt("sftp:create:BadCall", "Host should be a string or empty.");
      break;
    case 0:
      break;
    default:
      mexErrMsgIdAndTxt("sftp:create:BadCall", "Zero to four inputs required.");
  }

  /* Get input data. */
  host = NULL;
  port = NULL;
  user = NULL;
  pass = NULL;
  if (nrhs > 0 && mxGetNumberOfElements(prhs[0]) > 0) {
    host = mxArrayToString(prhs[0]);
  }
  if (nrhs > 1 && mxGetNumberOfElements(prhs[1]) > 0) {
    port = (unsigned int*) mxMalloc(sizeof(unsigned int));
    *port = mxGetScalar(prhs[1]);
  }
  if (nrhs > 2 && mxIsChar(prhs[2])) 
    user = mxArrayToString(prhs[2]);
  if (nrhs > 3 && mxIsChar(prhs[3]))
    pass = mxArrayToString(prhs[3]);
  
  /* Initialize output data. */
  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);

  /* Create the sftp connection handle. */
  conn = make_sftp_connection();
  if (! conn) {
    mexErrMsgIdAndTxt("sftp:create:MemoryError", 
                      "Could not create new SFTP connection");
  }
  
  /* Open the sftp connection if host is specified. */
  if (host) {
    open_sftp_connection(&rc, &message, conn, host, port, user, pass);
    if (rc != SSH_OK) {
      free_sftp_connection(conn);
      mexErrMsgIdAndTxt("sftp:create:ConnectionError", 
                        "SFTP connection failed (%d): %s.", rc, message);
    }
  }
  
  /* Set the output values. */
  *((uint64_T*) mxGetData(plhs[0])) = (uint64_T) conn;
  
  /* Free local data. */
  mxFree(host);
  mxFree(port);
  mxFree(user);
  mxFree(pass);
}


void mexsftp_delete( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
    
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs!=0)
    mexErrMsgIdAndTxt("sftp:delete:BadCall", "Zero outputs required.");
  if (nrhs!=1)
    mexErrMsgIdAndTxt("sftp:delete:BadCall", "One input required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1))
    mexErrMsgIdAndTxt("sftp:delete:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");

  /* Get the the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
   
  /* Close the sftp connection. */
  close_sftp_connection(conn);
  
  /* Free the connection. */
  free_sftp_connection(conn);
}
  

void mexsftp_connect( int nlhs, mxArray *plhs[],
                      int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *host, *user, *pass;
  unsigned int *port;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs!=0)
    mexErrMsgIdAndTxt("sftp:connect:BadCall", "Zero outputs required.");
  switch (nrhs) {
    case 5:
      if (! ((mxIsChar(prhs[4]) && mxGetM(prhs[4]) == 1) ||
             (mxIsNumeric(prhs[4]) && mxGetNumberOfElements(prhs[4]) == 0)))
        mexErrMsgIdAndTxt("sftp:connect:BadCall", "Password should be a string or empty.");
    case 4:
      if (! ((mxIsChar(prhs[3]) && mxGetM(prhs[3]) == 1) ||
             (mxIsNumeric(prhs[3]) && mxGetNumberOfElements(prhs[3]) == 0)))
        mexErrMsgIdAndTxt("sftp:connect:BadCall", "User should be a string or empty.");
    case 3:
      if (! (mxIsNumeric(prhs[2]) && mxGetNumberOfElements(prhs[2]) < 2))
        mexErrMsgIdAndTxt("sftp:connect:BadCall", "Port shoud be numeric scalar or empty.");
    case 2:
      if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
        mexErrMsgIdAndTxt("sftp:connect:BadCall", "Host should be a string.");
      break;
    case 1:
      if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
             && mxGetNumberOfElements(prhs[0]) == 1))
        mexErrMsgIdAndTxt("sftp:connect:BadCall", 
                          "Connection must be scalar of class uint64 (pointers).");
    default:
      mexErrMsgIdAndTxt("sftp:connect:BadCall", "Two to five inputs required.");
  }

  /* Get input data. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  host = mxArrayToString(prhs[1]);
  port = NULL;
  user = NULL;
  pass = NULL;
  if (nrhs > 2 && mxGetNumberOfElements(prhs[2])) {
    port = (unsigned int *) mxMalloc(sizeof(unsigned int));
    *port = mxGetScalar(prhs[2]);
  }
  if (nrhs > 3 && mxIsChar(prhs[3])) 
    user = mxArrayToString(prhs[3]);
  if (nrhs > 4 && mxIsChar(prhs[4]))
    pass = mxArrayToString(prhs[4]);
  
  /* Initialize output data. */
  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);

  /* Create the sftp connection handle. */
  open_sftp_connection(&rc, &message, conn, host, port, user, pass);

  /* Check that connection succeed. */
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:connect:ConnectionError", 
                      "SFTP connection failed (%d): %s.", rc, message);
  
  /* Free internal data. */
  mxFree(host);
  mxFree(port);
  mxFree(user);
  mxFree(pass);
}


void mexsftp_disconnect( int nlhs, mxArray *plhs[],
                         int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
    
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs!=0)
    mexErrMsgIdAndTxt("sftp:disconnect:BadCall", "Zero outputs required.");
  if (nrhs!=1)
    mexErrMsgIdAndTxt("sftp:disconnect:BadCall", "One input required.");
  if (!(mxGetClassID(prhs[0]) == mxUINT64_CLASS
        && mxGetM(prhs[0]) == 1 && mxGetN(prhs[0]) == 1))
    mexErrMsgIdAndTxt("sftp:disconnect:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");

  /* Get the the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
   
  /* Close the sftp connection. */
  close_sftp_connection(conn);
}


void mexsftp_pwd( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  char *pwd;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs > 1)
    mexErrMsgIdAndTxt("sftp:pwd:BadCall", "One output required.");
  if (nrhs != 1)
    mexErrMsgIdAndTxt("sftp:pwd:BadCall", "One input required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:pwd:BadCall", 
                      "Connection must be scalar of class uint64 (pointers).");

  /* Get the the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get working directory if available. */
  pwd = NULL;
  if (conn) {
    pwd = conn->pwd;
  }
  
  /* Set output values. */
  if (pwd)
    plhs[0] = mxCreateString(pwd);
  else
    plhs[0] = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxREAL);
}


void mexsftp_cwd( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *path;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 0)
    mexErrMsgIdAndTxt("sftp:cwd:BadCall", "Zero outputs required.");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("sftp:cwd:BadCall", "Two inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:cwd:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:cwd:BadCall", "Path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the directory. */
  path = mxArrayToString(prhs[1]);
  
  /* Change the working directory. */
  cwd_sftp_connection(&rc, &message, conn, path);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:cwd:CWDError", 
                      "SFTP change of directory failed (%d): %s.", rc, message);
    
  /* Free internal data. */
  mxFree(path);
}


void mexsftp_lsfile( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[] )
{
  const int nfield = 5;
  const char* fields[] = {"name", "bytes", "isdir", "date", "datenum"};
  struct tm *mtime;
  sftp_attributes atts;
  sftp_connection conn;
  const char *message;
  int rc;
  char *path;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 1)
    mexErrMsgIdAndTxt("sftp:lsfile:BadCall", "One output required.");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("sftp:lsfile:BadCall", "Two inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:lsfile:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:lsfile:BadCall", "Path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the path. */
  path = mxArrayToString(prhs[1]);
  
  /* Initialize output data. */
  plhs[0] = mxCreateStructMatrix(1, 1, nfield, fields);
  
  /* Get attributes of path. */
  lsfile_sftp_connection(&rc, &message, &atts, conn, path);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:lsfile:ListError", 
                      "SFTP stat failed (%d): %s.", rc, message);
  
  /* Set output values. */
  mxSetField(plhs[0], 0, "name", mxCreateString(atts->name));
  mxSetField(plhs[0], 0, "bytes", mxCreateDoubleScalar(atts->size));
  mxSetField(plhs[0], 0, "isdir", mxCreateLogicalScalar(isdir_sftp_attributes(atts)));
  mxSetField(plhs[0], 0, "date",  mxCreateDoubleMatrix(1, 6, mxREAL));
  mtime = localtime((time_t *) &(atts->mtime));
  if (mtime) {
    mxGetPr(mxGetField(plhs[0], 0, "date"))[0] = mtime->tm_year + 1900;
    mxGetPr(mxGetField(plhs[0], 0, "date"))[1] = mtime->tm_mon + 1;
    mxGetPr(mxGetField(plhs[0], 0, "date"))[2] = mtime->tm_mday;
    mxGetPr(mxGetField(plhs[0], 0, "date"))[3] = mtime->tm_hour;
    mxGetPr(mxGetField(plhs[0], 0, "date"))[4] = mtime->tm_min;
    mxGetPr(mxGetField(plhs[0], 0, "date"))[5] = mtime->tm_sec;
  }
  
  /* Free internal data. */
  sftp_attributes_free(atts);
  mxFree(path);
}

void mexsftp_lsdir( int nlhs, mxArray *plhs[],
                    int nrhs, const mxArray *prhs[] )
{
  const int nfield = 5;
  const char* fields[] = {"name", "bytes", "isdir", "date", "datenum"};
  struct tm *mtime;
  size_t count;
  mwIndex index;
  sftp_attributes atts;
  sftp_attributes_list list, iter;
  sftp_connection conn;
  const char *message;
  int rc;
  char *path;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 1)
    mexErrMsgIdAndTxt("sftp:lsdir:BadCall", "One output required.");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("sftp:lsdir:BadCall", "Two inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:lsdir:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:lsdir:BadCall", "Path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the path. */
  path = mxArrayToString(prhs[1]);
  
  /* Get attributes of path, if it exists. */
  lsdir_sftp_connection(&rc, &message, &list, conn, path);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:lsdir:ListError", 
                      "SFTP stat failed (%d): %s.", rc, message);

  /* Initialize output data. */
  count = length_sftp_attributes_list(list);
  plhs[0] = mxCreateStructMatrix(count, 1, nfield, fields);
  
  /* Set output values */  
  for (iter = head_sftp_attributes_list(list), index=0;
       iter != lend_sftp_attributes_list(list); 
       iter = next_sftp_attributes_list(iter), index++) {
    atts = atts_sftp_attributes_list(iter);
    mxSetField(plhs[0], index, "name", mxCreateString(atts->name));
    mxSetField(plhs[0], index, "bytes", mxCreateDoubleScalar(atts->size));
    mxSetField(plhs[0], index, "isdir", mxCreateLogicalScalar(isdir_sftp_attributes(atts)));
    mxSetField(plhs[0], index, "date",  mxCreateDoubleMatrix(1, 6, mxREAL));
    mtime = localtime((time_t *) &(atts->mtime));
    if (mtime) {
      mxGetPr(mxGetField(plhs[0], index, "date"))[0] = mtime->tm_year + 1900;
      mxGetPr(mxGetField(plhs[0], index, "date"))[1] = mtime->tm_mon + 1;
      mxGetPr(mxGetField(plhs[0], index, "date"))[2] = mtime->tm_mday;
      mxGetPr(mxGetField(plhs[0], index, "date"))[3] = mtime->tm_hour;
      mxGetPr(mxGetField(plhs[0], index, "date"))[4] = mtime->tm_min;
      mxGetPr(mxGetField(plhs[0], index, "date"))[5] = mtime->tm_sec;
    }
  }
  
  /* Free internal data. */
  free_sftp_attributes_list(list);
  mxFree(path);
}

void mexsftp_lsglob( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[] )
{
  const int nfield = 5;
  const char* fields[] = {"name", "bytes", "isdir", "date", "datenum"};
  struct tm *mtime;
  size_t count;
  mwIndex index;
  sftp_attributes atts;
  sftp_attributes_list list, iter;
  sftp_connection conn;
  const char *message;
  int rc;
  char *glob;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 1)
    mexErrMsgIdAndTxt("sftp:lsglob:BadCall", "One output required.");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("sftp:lsglob:BadCall", "Two inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:lsglob:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:lsglob:BadCall", "Glob should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the glob pattern. */
  glob = mxArrayToString(prhs[1]);
  
  /* Get attributes of path, if it exists. */
  lsglob_sftp_connection(&rc, &message, &list, conn, glob);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:lsglob:ListError", 
                      "SFTP stat failed (%d): %s.", rc, message);

  /* Initialize output data. */
  count = length_sftp_attributes_list(list);
  plhs[0] = mxCreateStructMatrix(count, 1, nfield, fields);
  
  /* Set output values */  
  for (iter = head_sftp_attributes_list(list), index=0;
       iter != lend_sftp_attributes_list(list); 
       iter = next_sftp_attributes_list(iter), index++) {
    atts = atts_sftp_attributes_list(iter);
    mxSetField(plhs[0], index, "name", mxCreateString(atts->name));
    mxSetField(plhs[0], index, "bytes", mxCreateDoubleScalar(atts->size));
    mxSetField(plhs[0], index, "isdir", mxCreateLogicalScalar(isdir_sftp_attributes(atts)));
    mxSetField(plhs[0], index, "date",  mxCreateDoubleMatrix(1, 6, mxREAL));
    mtime = localtime((time_t *) &(atts->mtime));
    if (mtime) {
      mxGetPr(mxGetField(plhs[0], index, "date"))[0] = mtime->tm_year + 1900;
      mxGetPr(mxGetField(plhs[0], index, "date"))[1] = mtime->tm_mon + 1;
      mxGetPr(mxGetField(plhs[0], index, "date"))[2] = mtime->tm_mday;
      mxGetPr(mxGetField(plhs[0], index, "date"))[3] = mtime->tm_hour;
      mxGetPr(mxGetField(plhs[0], index, "date"))[4] = mtime->tm_min;
      mxGetPr(mxGetField(plhs[0], index, "date"))[5] = mtime->tm_sec;
    }
  }
  
  /* Free internal data. */
  free_sftp_attributes_list(list);
  mxFree(glob);
}

void mexsftp_mkdir( int nlhs, mxArray *plhs[],
                    int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *path;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 0)
    mexErrMsgIdAndTxt("sftp:mkdir:BadCall", "Zero outputs required.");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("sftp:mkdir:BadCall", "Two inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:mkdir:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:mkdir:BadCall", "Path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the new directory. */
  path = mxArrayToString(prhs[1]);
  
  /* Create the new directory. */
  mkdir_sftp_connection(&rc, &message, conn, path);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:mkdir:MkdirError", 
                      "SFTP mkdir failed (%d): %s.", rc, message);

  /* Free internal data. */
  mxFree(path);
}


void mexsftp_rmdir( int nlhs, mxArray *plhs[],
                    int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *path;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 0)
    mexErrMsgIdAndTxt("sftp:rmdir:BadCall", "Zero outputs required.");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("sftp:rmdir:BadCall", "Two inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:rmdir:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:rmdir:BadCall", "Path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the directory. */
  path = mxArrayToString(prhs[1]);
  
  /* Delete the directory. */
  rmdir_sftp_connection(&rc, &message, conn, path);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:rmdir:RmdirError", 
                      "SFTP rmdir failed (%d): %s.", rc, message);

  /* Free internal data. */
  mxFree(path);
}


void mexsftp_rename( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *opath, *npath;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 0)
    mexErrMsgIdAndTxt("sftp:rename:BadCall", "Zero outputs required.");
  if (nrhs != 3)
    mexErrMsgIdAndTxt("sftp:rename:BadCall", "Three inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:rename:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:rename:BadCall", "Old path should be a string.");
  if (! (mxIsChar(prhs[2]) && mxGetM(prhs[2]) == 1))
    mexErrMsgIdAndTxt("sftp:rename:BadCall", "New path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the old and new paths. */
  opath = mxArrayToString(prhs[1]);
  npath = mxArrayToString(prhs[2]);
  
  /* Rename the file or directory. */
  rename_sftp_connection(&rc, &message, conn, opath, npath);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:rename:RenameError", 
                      "SFTP rename failed (%d): %s.", rc, message);

  /* Free internal data. */
  mxFree(opath);
  mxFree(npath);
}


void mexsftp_delfile( int nlhs, mxArray *plhs[],
                      int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *path;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 0)
    mexErrMsgIdAndTxt("sftp:delfile:BadCall", "Zero outputs required.");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("sftp:delfile:BadCall", "Two inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:delfile:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:delfile:BadCall", "Path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the path. */
  path = mxArrayToString(prhs[1]);
    
  /* Delete the file. */
  delfile_sftp_connection(&rc, &message, conn, path);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:delfile:DeleteError", 
                      "SFTP delete failed (%d): %s.", rc, message);

  /* Free internal data. */
  mxFree(path);
}


void mexsftp_getfile( int nlhs, mxArray *plhs[],
                      int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *rpath, *lpath;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 0)
    mexErrMsgIdAndTxt("sftp:getfile:BadCall", "Zero outputs required.");
  if (nrhs != 3)
    mexErrMsgIdAndTxt("sftp:getfile:BadCall", "Three inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:getfile:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:getfile:BadCall", "Remote path should be a string.");
  if (! (mxIsChar(prhs[2]) && mxGetM(prhs[2]) == 1))
    mexErrMsgIdAndTxt("sftp:getfile:BadCall", "Local path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the paths. */
  rpath = mxArrayToString(prhs[1]);
  lpath = mxArrayToString(prhs[2]);
    
  /* Get the file. */
  getfile_sftp_connection(&rc, &message, conn, rpath, lpath);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:getfile:GetError", 
                      "SFTP get failed (%d): %s.", rc, message);

  /* Free internal data. */
  mxFree(lpath);
  mxFree(rpath);
}


void mexsftp_putfile( int nlhs, mxArray *plhs[],
                      int nrhs, const mxArray *prhs[] )
{
  sftp_connection conn;
  const char *message;
  int rc;
  char *lpath, *rpath;
  
  /* Check for proper number of arguments, dimensions and types. */
  if (nlhs != 0)
    mexErrMsgIdAndTxt("sftp:putfile:BadCall", "Zero outputs required.");
  if (nrhs != 3)
    mexErrMsgIdAndTxt("sftp:putfile:BadCall", "Three inputs required.");
  if (! (mxGetClassID(prhs[0]) == mxUINT64_CLASS
         && mxGetNumberOfElements(prhs[0]) == 1) )
    mexErrMsgIdAndTxt("sftp:putfile:BadCall", 
                      "Connection must be scalar of class uint64 (pointer).");
  if (! (mxIsChar(prhs[1]) && mxGetM(prhs[1]) == 1))
    mexErrMsgIdAndTxt("sftp:putfile:BadCall", "Remote path should be a string.");
  if (! (mxIsChar(prhs[2]) && mxGetM(prhs[2]) == 1))
    mexErrMsgIdAndTxt("sftp:putfile:BadCall", "Local path should be a string.");
  
  /* Get the sftp connection handle. */
  conn = *((sftp_connection *) mxGetData(prhs[0]));
  
  /* Get the paths. */
  lpath = mxArrayToString(prhs[1]);
  rpath = mxArrayToString(prhs[2]);
    
  /* Put the file. */
  putfile_sftp_connection(&rc, &message, conn, lpath, rpath);
  if (rc != SSH_OK)
    mexErrMsgIdAndTxt("sftp:putfile:PutError", 
                      "SFTP put failed (%d): %s.", rc, message);

  /* Free internal data. */
  mxFree(rpath);
  mxFree(lpath);
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  char* funcname;
  void (*funcptr)(int, mxArray **, int, const mxArray **);
      
  /* Check for proper number of arguments. */
  if (nrhs<1)
    mexErrMsgIdAndTxt("sftp:mexsftp:BadCall", "Missing function name.");

  /* Check for proper types and dimensions. */
  if (!(mxIsChar(prhs[0]) && mxGetM(prhs[0]) == 1))
    mexErrMsgIdAndTxt("sftp:mexsftp:BadCall", "Function name not a string.");
  
  /* Get the function name as C string. */
  funcname = mxArrayToString(prhs[0]);
  
  /* Choose the function to call. */
  funcptr = NULL;
  if (0 == strcmp(funcname, "create"))
    funcptr = &mexsftp_create;
  else if (0 == strcmp(funcname, "delete"))
    funcptr = &mexsftp_delete;
  else if (0 == strcmp(funcname, "connect"))
    funcptr = &mexsftp_connect;
  else if (0 == strcmp(funcname, "disconnect"))
    funcptr = &mexsftp_disconnect;
  else if (0 == strcmp(funcname, "pwd"))
    funcptr = &mexsftp_pwd;
  else if (0 == strcmp(funcname, "cwd"))
    funcptr = &mexsftp_cwd;
  else if (0 == strcmp(funcname, "lsfile"))
    funcptr = &mexsftp_lsfile;
  else if (0 == strcmp(funcname, "lsdir"))
    funcptr = &mexsftp_lsdir;
  else if (0 == strcmp(funcname, "lsglob"))
    funcptr = &mexsftp_lsglob;
  else if (0 == strcmp(funcname, "mkdir"))
    funcptr = &mexsftp_mkdir;
  else if (0 == strcmp(funcname, "rmdir"))
    funcptr = &mexsftp_rmdir;
  else if (0 == strcmp(funcname, "rename"))
    funcptr = &mexsftp_rename;
  else if (0 == strcmp(funcname, "delfile"))
    funcptr = &mexsftp_delfile;
  else if (0 == strcmp(funcname, "getfile"))
    funcptr = &mexsftp_getfile;
  else if (0 == strcmp(funcname, "putfile"))
    funcptr = &mexsftp_putfile;
    
  /* Free internal variables. */
  mxFree(funcname);
  
  /* Check if function exists. */
  if (!funcptr)
    mexErrMsgIdAndTxt("sftp:mexsftp:BadCall", "Unknown function.");
  
  /* Call the required function with the right parameters. */
  (*funcptr)(nlhs, plhs, nrhs - 1, &prhs[1] );
}
