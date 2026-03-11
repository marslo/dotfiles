#=============================================================================
#     FileName : gh-ops-preview.jq
#       Author : marslo
#      Created : 2026-02-12 22:46:32
#   LastChange : 2026-03-10 20:36:34
#=============================================================================

# ansi color helper
def c(code; text): "\u001b[" + code + "m" + text + "\u001b[0m";

def status_bar:
  (
    # check PR state first
    if .state == "MERGED" then c("35"; "✔ Merged")                   # magenta '✔ Merged'
    elif .state == "CLOSED" then c("31"; "✖ Closed")                 # red '✖ Closed'

    # if status is OPEN, check mergeable status
    elif .mergeable == "MERGEABLE" then
       if .reviewDecision == "APPROVED" then c("32"; "✔ Mergeable")  # green ✔ Mergeable
       else c( "32"; "• Mergeable" ) end                             # green • Mergeable (not approved yet)
    elif .mergeable == "CONFLICTING" then c( "31"; "✖ Conflict" )    # red ✖ Conflict

    # handle in-progress or unknown states
    else c( "34"; "? Checking..." ) end                              # blue '? Checking...'
  )
  + "\t" +
  (
    # if PR is already merged or closed, hide the Review status on the right
    if .state == "MERGED" or .state == "CLOSED" then ""
    elif .reviewDecision == "APPROVED" then c("32"; "[Approved]")                    # green [Approved]
    elif .reviewDecision == "CHANGES_REQUESTED" then c("31"; "[Changes Requested]")  # red [Changes Requested]
    else c( "33"; "[Review Required]" ) end                                          # yellow [Review Required]
  );

# Label
def labels_section:
  ( .labels | map(.name) ) as $list |
  (
    if ( $list | length ) > 0 then
      c( "33"; "Labels:" ) + " " + ( $list | map(c("0;34"; "[" + . + "]")) | join(" ") )
    else
      c( "2;3;37"; "Labels: N/A" )
    end
  );

# Reviewers
def reviewers_section:
  ( .reviewRequests | map(.login // .slug) | unique ) as $list |
  if ( $list | length ) > 0 then
    c( "36"; "Reviewers: " ) + ( $list | join(", ") )
  else
    c( "37;2;3"; "Reviewers: N/A" )
  end;

# Latest Reviews
def reviews_section:
  ( .reviews | group_by(.author.login) | map(last) ) as $list |
  c("35"; "Latest Reviews:") +
  (
    if ($list | length) > 0 then
       "\n" +
       ( $list | map(
                     if .state == "APPROVED" then c("32"; "✔ " + .author.login)
                     elif .state == "CHANGES_REQUESTED" then c("31"; "✖ " + .author.login)
                     else "• " + .author.login end
                    ) | join("\n")
       )
    else
       " " + c( "37;2;3"; "N/A" )
    end
  );

# main output
status_bar + "\n" +
"\n" + labels_section +
"\n" + reviewers_section +
"\n" + reviews_section +
"\n\n--------------------------------------\n" +
( .body | gsub("(?m)^[ \t]+"; "") | gsub("(?s)[ \t]*<!--.*?-->[ \t]*\n?"; "") )
