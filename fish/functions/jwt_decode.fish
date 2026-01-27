function jwt_decode
    # Remove "Bearer " prefix if it exists (case-insensitive)
    set -l token (string replace -ir '^Bearer\s+' '' -- $argv[1])

    echo $token | jq -R 'split(".") | .[0:2] | map(gsub("-"; "+") | gsub("_"; "/") | gsub("%3D"; "=") | @base64d) | map(fromjson)'
end
