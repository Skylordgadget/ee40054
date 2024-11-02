def get_strip(indices, i, k):

    y, x = indices[i]
    prev_y, prev_x = indices[i-1]

    dir_y, dir_x = y-prev_y, x-prev_x
    offset = k // 2

    if dir_y == 0:
        old = [(yy, x - dir_x * (offset+1)) for yy in range(y-offset, y+offset+1)]
        new = [(yy, x + dir_x * offset) for yy in range(y-offset, y+offset+1)]
    else:
        old = [(y - dir_y * (offset+1), xx) for xx in range(x - offset, x + offset+1)]
        new = [(y + dir_y * offset, xx) for xx in range(x - offset, x + offset+1)]

    return old, new

def get_zigzag(n_row, n_col, k):

    indices = []
    offset = k // 2

    for i in range(offset, n_row-offset):
        coordinates = [[i, j] for j in range(offset, n_col-offset)]
        if i % 2 == 0:
            coordinates = coordinates[::-1]
        indices += coordinates

    return indices

indices = get_zigzag(9,9,3)

old, new = get_strip(indices,1,3)
print("done")