Some git utils ... one day I may merge with other similar repos ... for now I'm keeping it simple.

<table>

<tr>
<td>gitr status|log|add-commit|pull|push|du -r destination repo -s source branch -d destination -l log level branch dir1 dir2</td>
<td>Recurse through dir1, dir2, etc. doing a git status / log / pull / push on all git repos.  Or a simple (non-git) du command on all git repos.  add-commit will automatically add all changes (including deletions) and commit them ... useful when using git to automatically back up all changes.  Doesn't yet handle bare repos.</td>
</tr>

<tr>
<td>git-fn</td>
<td>Provide utility functions.</td>
</tr>

<tr>
<td>git-recurse command dir1 dir2</td>
<td>Recurse through dir1, dir2, etc. doing "command" on all git repos.  Doesn't yet handle bare repos.</td>
</tr>

<tr>
<td>svn-git-migrate</td>
</td>Simplify task of migrating from svn to git.  Requires svn2git.</td>
</tr>

</table>


