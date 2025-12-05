command -v python3 >/dev/null 2>&1 || { echo "python3 is required"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }

get_query() {
  local q=""
  if [ $# -ge 2 ] && { [ "$1" = "-q" ] || [ "$1" = "--query" ]; }; then q="$2"; shift 2; fi
  echo "$q"
}

encode_query() {
  python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1" || exit 1
}

fetch_results() {
  local url="$1" ua="$2" proxy="${ENFO_PROXY:-}"
  if [ -n "$proxy" ]; then
    curl -s -A "$ua" --proxy "$proxy" "$url"
  else
    curl -s -A "$ua" "$url"
  fi
}

parse_results() {
  local engine="$1" html="$2" eu="$3" et="$4"
  if [ "$engine" = "Google" ]; then
    echo "$html" | sed -n 's/.*<a href="\([^\"]*\)".*/\1/p' | grep '^/url?q=' | sed 's|^/url?q=||;s|&sa=.*$||' | grep -v 'webcache.googleusercontent.com' | head -10 > "$eu"
    echo "$html" | sed -n 's/.*<h3 class="[^"]*">\([^<]*\)<.*/\1/p' | head -10 > "$et"
  elif [ "$engine" = "DuckDuckGo" ]; then
    echo "$html" | grep -o '<a rel="nofollow" class="result__a" href="[^"]*"' | sed 's/.*href="\([^\"]*\)"/\1/' | head -10 > "$eu"
    echo "$html" | grep -o '<a rel="nofollow" class="result__a" [^>]*>[^<]*' | sed 's/.*>//' | head -10 > "$et"
  else
    echo "$html" | grep -o '<li class="b_algo"><h2><a href="[^"]*"' | sed 's/.*href="\([^\"]*\)"/\1/' | head -10 > "$eu"
    echo "$html" | grep -o '<li class="b_algo"><h2><a [^>]*>[^<]*' | sed 's/.*>//' | head -10 > "$et"
  fi
}

copy_clipboard() {
  local f="$1"
  if command -v xclip >/dev/null 2>&1; then
    echo -n "$f" | xclip -selection clipboard
    echo "(Copied to clipboard with xclip)"
  elif command -v xsel >/dev/null 2>&1; then
    echo -n "$f" | xsel --clipboard --input
    echo "(Copied to clipboard with xsel)"
  elif command -v pbcopy >/dev/null 2>&1; then
    echo -n "$f" | pbcopy
    echo "(Copied to clipboard with pbcopy)"
  elif command -v clip >/dev/null 2>&1; then
    echo -n "$f" | clip
    echo "(Copied to clipboard with clip)"
  else
    echo "(No clipboard utility found)"
  fi
}

main() {
        # ---
        # Automatic Startup Setup (commented out)
        #
        # Windows (Run key, PowerShell):
        #   Uncomment and run this in PowerShell to enable automatic startup:
        #   $scriptPath = "$PWD\enfo.sh"
        #   $runCmd = "bash `\"$scriptPath`\""
        #   Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'EnfoScript' -Value $runCmd
        #
        # Linux/Mac (shell profile):
        #   Uncomment to run enfo.sh at login:
        #   bash ~/Desktop/Projects/enfo/enfo.sh &
        #
        # Linux (systemd user service):
        #   Create ~/.config/systemd/user/enfo.service with:
        #     [Unit]
        #     Description=Enfo Search Script
        #     [Service]
        #     ExecStart=/usr/bin/bash /home/youruser/Desktop/Projects/enfo/enfo.sh
        #     [Install]
        #     WantedBy=default.target
        #   Enable with:
        #     systemctl --user enable enfo
        #     systemctl --user start enfo
        #
        # Mac (launchd):
        #   Use launchd or Automator for background startup.
        # ---
      # Uncomment the next line to ignore Ctrl+C (SIGINT) and other signals in the main script
      # trap '' SIGINT SIGTERM SIGQUIT SIGHUP SIGTSTP
    # Uncomment the next line to ignore Ctrl+C (SIGINT) and prevent script termination
    # trap '' SIGINT

    # To ignore Esc key in live preview mode, remove or modify the Esc check in the input loop
  if [ -f "enfo.conf" ]; then
    source "enfo.conf"
  fi
  local proxy="${ENFO_PROXY:-}" 
  local batch_file="${ENFO_BATCH:-}"
  local delay="${ENFO_DELAY:-}" # Rate Limit bro change in enfo.conf
  local include=""
  local exclude=""
  local live_mode=""
  local auto_mode=""
  local jobs=4 # Number of parallel jobs in auto mode add to 1 billion if you have a supercomputer
  LOG_RESULTS=1 # Set to 0 to disable logging
  LOG_FILE="results.log"
  while [ $# -gt 0 ]; do
    case "$1" in
      --proxy=*|-p=*)
        proxy="${1#*=}"
        export ENFO_PROXY="$proxy"
        ;;
      --batch=*|-b=*)
        batch_file="${1#*=}"
        ;;
      --delay=*|-d=*)
        delay="${1#*=}"
        ;;
      --include=*|-i=*)
        include="${1#*=}"
        ;;
      --exclude=*|-e=*)
        exclude="${1#*=}"
        ;;
      --live|-l)
        live_mode=1
        ;;
      --auto|-a)
        auto_mode=1
        ;;
      --jobs=*|-j=*)
        jobs="${1#*=}"
        ;;
      *)
        ;;
    esac
    shift
  done

  local e=("Google" "DuckDuckGo" "Bing")
  local u=("https://www.google.com/search?q=" "https://duckduckgo.com/html/?q=" "https://www.bing.com/search?q=")
  local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"

  run_query() {
    local q="$1"
    local enc=$(encode_query "$q")
    local eu=$(mktemp)
    local et=$(mktemp)
    trap "rm -f '$eu' '$et'" EXIT
    for i in 0 1 2; do
      echo -e "\nSearching ${e[$i]}: ${u[$i]}$enc"
      local h=$(fetch_results "${u[$i]}$enc" "$ua")
      [ -z "$h" ] && { echo "Failed to fetch results from ${e[$i]}"; > "$eu"; > "$et"; continue; }
      parse_results "${e[$i]}" "$h" "$eu" "$et"
      if [ -s "$eu" ] && [ -s "$et" ]; then
        local results=$(paste -d '\n' "$et" "$eu")
        if [ -n "$include" ]; then
          results=$(echo "$results" | grep -i "$include")
        fi
        if [ -n "$exclude" ]; then
          results=$(echo "$results" | grep -vi "$exclude")
        fi
        if [ "$LOG_RESULTS" -eq 1 ]; then
          echo "[$(date)] Query: $q | Engine: ${e[$i]}" >> "$LOG_FILE"
          if [ -n "$results" ]; then
            echo "$results" >> "$LOG_FILE"
          else
            echo "No results found." >> "$LOG_FILE"
          fi
          echo "---" >> "$LOG_FILE"
        fi
        if [ -n "$results" ]; then
          echo "$results" | awk 'NR%2{printf "\n%d. %s\n",++i,$0;next}{print $0}'
          local f=$(echo "$results" | awk 'NR==2')
          if [ -n "$f" ]; then
            echo -e "\nQuick Link: $f"
            copy_clipboard "$f"
          else
            echo -e "\nNo results found."
          fi
        else
          echo -e "\nNo results found."
        fi
      else
        echo -e "\nNo results found."
      fi
      > "$eu"
      > "$et"
    done
  }

  if [ -n "$auto_mode" ] || { [ -z "$batch_file" ] && [ -z "$live_mode" ]; }; then
    echo "Automated Test Mode: Trying random combinations in parallel ($jobs jobs) until a result is found. Press Ctrl+C to stop."
    found=0
    job_pids=()
    cleanup() {
      for pid in "${job_pids[@]}"; do
        kill "$pid" 2>/dev/null
      done
    }
    trap cleanup EXIT
    auto_worker() {
        # Uncomment the next line to ignore Ctrl+C (SIGINT) and other signals in each worker process
        # trap '' SIGINT SIGTERM SIGQUIT SIGHUP SIGTSTP
      while [ $found -eq 0 ]; do
        rand=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c 8)
        query="www.$rand.com"
        printf "\033c"
        echo "Testing: $query"
        result=$(run_query "$query")
        if [ "$LOG_RESULTS" -eq 1 ]; then
          echo "[$(date)] Query: $query" >> "$LOG_FILE"
          echo "$result" >> "$LOG_FILE"
          echo "---" >> "$LOG_FILE"
        fi
        if ! echo "$result" | grep -q "No results found."; then
          echo "Result found for $query!"
          found=1
          cleanup
          break
        fi
        sleep 1
      done
    }
    for ((i=0;i<jobs;i++)); do
      auto_worker &
      job_pids+=("$!")
    done
    wait
  elif [ -z "$batch_file" ]; then
    echo "Live Preview Mode: Type your query. Press Enter to run, Ctrl+C to exit."
    local last_time=0
    local initial="www..com"
    echo "Live Preview Mode: Edit the prompt below. Press Enter to run, Ctrl+C to exit."
    query="$initial"
    printf "\033c"
    echo "Live Preview Mode: Type your query. Results update after every keystroke. Press Ctrl+C or Esc to exit."
    result=$(run_query "$query")
    if [ "$LOG_RESULTS" -eq 1 ]; then
      echo "[$(date)] Query: $query" >> "$LOG_FILE"
      echo "$result" >> "$LOG_FILE"
      echo "---" >> "$LOG_FILE"
    fi
    while true; do
      IFS= read -rsn1 char
  
      if [[ "$char" == $'\003' || "$char" == $'\e' ]]; then
        echo -e "\nExiting live preview."
        break
      fi
    
      if [[ "$char" == $'\n' ]]; then
        continue
      fi
     
      if [[ "$char" == $'\177' ]]; then
        query="${query%?}"
      else
        query+="$char"
      fi
     t
      printf "\033c"
      echo "Live Preview: $query"

      result=$(run_query "$query")
      if [ "$LOG_RESULTS" -eq 1 ]; then
        echo "[$(date)] Query: $query" >> "$LOG_FILE"
        echo "$result" >> "$LOG_FILE"
        echo "---" >> "$LOG_FILE"
      fi
    done
  elif [ -n "$batch_file" ]; then
    if [ ! -f "$batch_file" ]; then
      echo "Batch file not found: $batch_file"; exit 1
    fi
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      echo -e "\n=== Query: $line ==="
      run_query "$line"
      if [ -n "$delay" ]; then
        sleep "$delay"
      fi
    done < "$batch_file"
  else
    local q=$(get_query "$@")
    run_query "$q"
  fi
}

main "$@"