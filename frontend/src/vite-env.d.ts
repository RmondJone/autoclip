/// <reference types="vite/client" />

declare module '*.svg' {
  const content: string
  // @ts-ignore
    export default content
}

declare module '*.svg?react' {
  import React from 'react'
  const ReactComponent: React.FunctionComponent<React.SVGProps<SVGSVGElement>>
  export default ReactComponent
}