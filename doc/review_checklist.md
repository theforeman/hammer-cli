PR review Checklist
-------------------
Before the PR in hammer project is merged the reviewer should check the following things:
- [ ] Related issue exists
- [ ] Commit message is in correct format 
- [ ] The patch fixes the problem described in the issue
- [ ] UX is consistent across commands
- [ ] The fix is in the right repo hammer core/hammer plugin/API
- [ ] It doesn't break compatibility for users
- [ ] It doesn't break compatibility for hammer plugins (even hammer-cli-foreman is extended by plugins)
- [ ] Strings are translated and the translations are properly formated
- [ ] Docs updated if changing documented patterns or adding new ones
- [ ] Tests for the new functionality/fix are added
- [ ] Automated tests are green
- [ ] Note if multiple commits needs squash on merge
