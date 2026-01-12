---
description: Proper bash guidelines
applyTo: '**/*.sh'
---

# Bash Scripting Guidelines

Proper guideling for writing quality bash and shell scripts. 

## Style and Format 

The following are style and formatting guidelines for bash scripts:
- use two spaces for indentation
- variables outside of a function should be in upper pascal case (e.g., MY_VARIABLE)
- variables inside of a function should be in lower snake case (e.g., my_variable)
- use `local` keyword for function scoped variables
- use `#!/usr/bin/env bash` as the shebang for better portability
- use the keyword `function` when defining functions
- use `\` to separate long commands into multiple lines

### Multi Line Outputs

When appending text to the bottom of a file: 
```bash
cat <<EOF >> filename.txt
Multi line text goes here.
EOF
```
