Some git utils ... one day I may merge with other similar repos ... but for now I'm keeping it simple.

<table>
<tr>

<td>git-fn</td>
<td>Provide usage() and parse_opts() functions for other git-r* commands.</td>
<td>git-recurse command dir1 dir2</td>
<td>Recurse through dir1, dir2, etc. doing "command" on all git repos.  Doesn't yet handle bare repos.</td>
<td>git-rpull -r destination repo -s source branch -d destination branch dir1 dir2</td>
<td>Recurse through dir1, dir2, etc. doing a git pull on all git repos.  Doesn't yet handle bare repos.</td>
<td>git-rpush -r destination repo -s source branch -d destination branch dir1 dir2</td>
<td>Recurse through dir1, dir2, etc. doing a git push on all git repos.  Doesn't yet handle bare repos.</td>

</tr>
</table>


