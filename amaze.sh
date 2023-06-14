#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

player_moving=0
# 0: not moving, 1: left (+x), 2: right (-x), 3: bottom (+y), 4: top (-y)
player_x=14
player_y=9
player_width=4
player_height=2

set_dimensions() {
  width=$(( $(tput cols) ))
  height=$(( $(tput lines) ))
  width=27
  height=29
}

move_block(){ # move player x steps in direction
  if [[ "$player_moving" -eq "0" ]]; then
    return;
  fi
  # get new position
  block_x=${BLOCKS[0]}
  block_y=${BLOCKS[1]}
  block_width=${BLOCKS[2]}
  block_height=${BLOCKS[3]}
  new_x=$block_x
  new_y=$block_y
  case "$1" in
    1)
      new_x=$(( block_x+1 ))
      ;;
    2)
      new_x=$(( block_x-1 ))
      ;;
    3)
      new_y=$(( block_y+1 ))
      ;;
    4)
      new_y=$(( block_y-1 ))
      ;;
  esac
  # check collision
  collides=0
  for (( j = 4; j < ${#BLOCKS[@]}; $(( j+=4 )) )); do
    block2_x=${BLOCKS[$j]}
    block2_y=${BLOCKS[$j+1]}
    block2_width=${BLOCKS[$j+2]}
    block2_height=${BLOCKS[$j+3]}
    block2_area_x=$(( block2_x + block2_width - 1 ))
    block2_area_y=$(( block2_y + block2_height - 1 ))
    case "$1" in
      1)
        if [[ $(( new_x + block_width - 1 )) -eq $(( block2_x )) ]]; then
          if [[ $new_y -ge $block2_y && $new_y -le $block2_area_y ]] || [[ $(( new_y + block_height - 1 )) -ge $block2_y && $new_y -le $block2_y ]]; then
            collides=1
          fi
        fi
        ;;
      2)
        if [[ $(( new_x )) -eq $(( block2_area_x )) ]]; then
          if [[ $new_y -ge $block2_y && $new_y -le $block2_area_y ]] || [[ $(( new_y + block_height - 1 )) -ge $block2_y && $new_y -le $block2_y ]]; then
            collides=1
          fi
        fi
        ;;
      3)
        if [[ $(( new_y + block_height - 1 )) -eq $(( block2_y )) ]]; then
          if [[ $new_x -ge $block2_x && $new_x -le $block2_area_x ]] || [[ $(( new_x + block_width - 1 )) -ge $block2_x && $new_x -le $block2_x ]]; then
            collides=1
          fi
        fi
        ;;
      4)
        if [[ $(( new_y )) -eq $(( block2_area_y )) ]]; then
          if [[ $new_x -ge $block2_x && $new_x -le $block2_area_x ]] || [[ $(( new_x + block_width - 1 )) -ge $block2_x && $new_x -le $block2_x ]]; then
            collides=1
          fi
        fi
        ;;
    esac
  done
  if [[ "$collides" -eq 1 ]]; then
    player_moving=0
  else
    player_x=$new_x
    player_y=$new_y
  fi
}

get_movement_direction(){
  if [[ "$player_moving" -eq "0" ]]; then
    while :
    do
      read -t 1 -n 1 key
      case "$key" in
        l)
          player_moving=1
          break;
          ;;
        h)
          player_moving=2
          break
          ;;
        j)
          player_moving=3
          break
          ;;
        k)
          player_moving=4
          break
          ;;
      esac
    done
  fi
}

set_objects(){
  BLOCKS=( $player_x $player_y $player_width $player_height 22 9 4 2 0 1 1 28 26 1 1 28 0 0 27 1 0 28 27 1 1 1 4 2 1 7 4 2 5 11 5 13 14 22 4 2 22 26 4 2 18 1 4 2 )
  # each 4 elements represent one block
  # order: x y width height
  # first 4 are reserved for player
}

render(){
  final_string=""
  for (( i = 0; i <= $(( height-1 )); i++ )); do
    for (( k = 0; k <= $(( width-1 )); k++ )); do
      printed=0
      for (( j = 0; j < ${#BLOCKS[@]}; $(( j+=4 )) )); do
        block_x=${BLOCKS[$j]}
        block_y=${BLOCKS[$j+1]}
        block_width=${BLOCKS[$j+2]}
        block_height=${BLOCKS[$j+3]}
        block_area_x=$(( block_x + block_width - 1 ))
        block_area_y=$(( block_y + block_height - 1 ))
        if [[ $i -ge $block_y ]] && [[ $i -le $block_area_y ]]; then
          if [[ ( $k -ge $block_x ) ]] && [[ ( $k -le $block_area_x  ) ]]; then
            if [[ "$j" -ne "0" ]]; then
              final_string="$final_string|"
            else final_string="$final_string${RED}|${NC}"
            fi
            printed=1
            break
          fi
        fi
      done
      if [[ "$printed" -eq "0" ]]; then
        final_string="$final_string."
      fi
    done
    final_string="$final_string\n"
  done
  if [[ ${#old_string} -ne 0 ]]; then
    for (( i = 0; i < ${#finaL_string}; i++ )); do
      if [[ ${old_string:$i:1} != ${final_string:$i:1} ]]; then
        continue;
      fi
      row=$((i/height))
      col=$((i%height))
      echo -ne "\033[<$row>;<$col>H${final_string:$i:1}"
    done
  else
    clear
    echo -ne "$final_string"
  fi
}

cycle(){
  while true
  do
    set_dimensions
    set_objects
    render
    get_movement_direction
    move_block $player_moving
    sleep 0.05 # you can try lower and higher values
  done
}

cycle
