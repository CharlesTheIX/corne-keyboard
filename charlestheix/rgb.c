#include QMK_KEYBOARD_H

static uint8_t default_hue;
static uint8_t default_sat;
static uint8_t default_val;

void keyboard_post_init_user(void) {
    default_hue = rgb_matrix_get_hue();
    default_sat = rgb_matrix_get_sat();
    default_val = rgb_matrix_get_val();
}

layer_state_t layer_state_set_user(layer_state_t state) {
    uint8_t layer = get_highest_layer(state);

    if (layer == 0) {
        rgb_matrix_sethsv_noeeprom(default_hue, default_sat, default_val);
    } else if (layer == 1) {
        rgb_matrix_sethsv_noeeprom(170, 255, 255); // Blue
    } else if (layer == 2) {
        rgb_matrix_sethsv_noeeprom(85, 255, 255); // Green
    }

    return state;
}