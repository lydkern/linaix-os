#!/usr/bin/sh

#
#    Copyright (C) 2025 NullPotOS Project
#    Follow MIT License
#

find includes/ kernel/ -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) -exec clang-format -i {} +