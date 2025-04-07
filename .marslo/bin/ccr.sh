#!/usr/bin/env bash
#=============================================================================
#     FileName : ccr.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-03-25 08:29:23
#   LastChange : 2025-04-07 15:36:00
#=============================================================================

set -euo pipefail

# ccr - [C]hatGPT [C]ode [R]eview
#
# +----------------------+--------------------+---------------------+
# | ENVIRONMENT VARIABLE | DEFAULT VALUE      | NOTE                |
# +----------------------+--------------------+---------------------+
# | COMMITX_MODEL        | gpt-4-turbo        | gpt-4,gpt-3.5-turbo |
# | COMMITX_TEMPERATURE  | 0.3                | -                   |
# | OPENAI_API_KEY       | env.OPENAI_API_KEY | *mandatory          |
# +----------------------+--------------------+---------------------+

MODEL="${COMMITX_MODEL:-gpt-4-turbo}"
TEMPERATURE="${COMMITX_TEMPERATURE:-0.3}"
OPENAI_API_KEY="${OPENAI_API_KEY:? OPENAI_API_KEY not set}"
diff=$(git --no-pager diff --color=never HEAD^..HEAD --unified=0)
prompt="You are a Principal Software Architect reviewing a Git diff.

You may not have the full code context, but please still provide a professional code review.

Focus on:
- What the changes are doing
- Code quality, style, naming, structure
- Potential bugs or anti-patterns
- Suggestions for improvement

Use markdown. Be helpful, concise, and insightful.

--- START DIFF ---
${diff}
--- END DIFF ---"

curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg model "$MODEL" \
    --arg temp "$TEMPERATURE" \
    --arg prompt "$prompt" \
    ' {
      model: $model,
      temperature: ($temp | tonumber),
      messages: [
        { role: "system", content: "You are a senior engineer performing code review." },
        { role: "user", content: $prompt }
      ]
    }')" |
jq -r '.choices[0].message.content'

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
