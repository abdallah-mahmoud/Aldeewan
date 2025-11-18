// This tells TypeScript that any import ending in .png is a valid module
// and its default export is a string (the path to the image).
declare module '*.png' {
  const value: string;
  export default value;
}

// You can do the same for other file types you might use
declare module '*.svg' {
  const value: string;
  export default value;
}

declare module '*.jpg' {
    const value: string;
    export default value;
}

declare module '*.jpeg' {
    const value: string;
    export default value;
}