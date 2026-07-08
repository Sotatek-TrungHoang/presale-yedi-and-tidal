import defaultTheme from "tailwindcss/defaultTheme";

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php",
        "./storage/framework/views/*.php",
        "./resources/**/*.blade.php",
        "./resources/**/*.js",
        "./resources/**/*.vue",
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ["Figtree", ...defaultTheme.fontFamily.sans],
                sora: ["Sora", ...defaultTheme.fontFamily.sans],
            },
            colors: {
                input: "#F3F3F3",
                yediBg: "#F0E4D4",
                tidalBg: "#F3F3F3",
                yediAccent: "#EF9F1F",
                tidalAccent: "#3E4DB0",
            },
        },
    },
    plugins: [],
};
