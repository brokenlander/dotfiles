#!/bin/bash
# Color capability test script

echo "=== Terminal Color Capability Test ==="
echo ""

echo "1. Environment Variables:"
echo "   TERM=$TERM"
echo "   COLORTERM=$COLORTERM"
echo "   SSH_CLIENT=${SSH_CLIENT:-not set}"
echo ""

echo "2. Testing 256-color support:"
printf "   "
for i in {0..255}; do
    printf "\033[38;5;${i}m█\033[0m"
    if [ $((($i + 1) % 36)) -eq 0 ]; then
        printf "\n   "
    fi
done
echo ""
echo ""

echo "3. Testing RGB/Truecolor support:"
echo "   This text should be ORANGE if truecolor works:"
printf "   \033[38;2;255;100;0m████ TRUECOLOR TEST ████\033[0m\n"
echo ""
printf "   This should be PURPLE:\n"
printf "   \033[38;2;128;0;128m████ PURPLE TEST ████\033[0m\n"
echo ""

echo "4. Neovim color check:"
if command -v nvim &>/dev/null; then
    nvim --version | head -1
    echo "   Run: nvim +':echo has(\"termguicolors\")' +':sleep 2' +':q'"
else
    echo "   Neovim not found"
fi
echo ""

echo "5. Tmux info:"
if command -v tmux &>/dev/null; then
    echo "   Tmux version: $(tmux -V)"
    if [ -n "$TMUX" ]; then
        echo "   Inside tmux: YES"
        echo "   TERM inside tmux: $TERM"
    else
        echo "   Inside tmux: NO"
    fi
else
    echo "   Tmux not installed"
fi
echo ""

echo "=== Instructions ==="
echo "1. Run this OUTSIDE tmux: bash ~/dotfiles/scripts/test-colors.sh"
echo "2. Then run INSIDE tmux: bash ~/dotfiles/scripts/test-colors.sh"
echo "3. Compare the results to see where colors break"
