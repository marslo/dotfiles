# gh-ops-preview.jq

def c(code; text): "\u001b[" + code + "m" + text + "\u001b[0m";

def status_bar:
  (
    if .mergeable == "MERGEABLE" then
       if .reviewDecision == "APPROVED" then c("32"; "✔ Mergeable Status")
       else c( "32"; "• Mergeable Status" ) end
    else c( "31"; "✖ Conflict" ) end
  )
  + "\t" +
  (
    if .reviewDecision == "APPROVED" then c("32"; "[Approved]")
    elif .reviewDecision == "CHANGES_REQUESTED" then c("31"; "[Changes Requested]")
    else c( "33"; "[Review Required]" ) end
  );

# Reviewers
def reviewers_section:
  ( .reviewRequests | map(.login // .slug) | unique ) as $list |
  "\n" + c( "36"; "Reviewers:" ) + " " +
  (
    if ( $list | length ) > 0 then
       ( $list | join(", ") )
    else
       c( "37;2;3"; "N/A" )
    end
  );

# Latest Reviews
def reviews_section:
  ( .reviews | group_by(.author.login) | map(last) ) as $list |
  "\n" + c("35"; "Latest Reviews:") +
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
reviewers_section +
reviews_section +
"\n\n--------------------------------------\n" +
.body
