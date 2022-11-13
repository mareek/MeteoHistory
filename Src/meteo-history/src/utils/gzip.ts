import init, { decompressStringGzip } from "wasm-gzip";

async function decompressResponse(response: Response): Promise<string | undefined> {
    return await response.text();
    const globalObject: any = window;
    if (!!globalObject?.DecompressionStream) {
        return await decompressNative(await response.blob());
    } else {
        return decompressUsingLib(await response.arrayBuffer());
    }
}

async function decompressNative(blob: Blob): Promise<string | undefined> {
    const globalObject: any = window;
    const decompressionStream = new globalObject.DecompressionStream("gzip");
    const blobStream : any  = blob.stream();
    const decompressedStream : ReadableStream = blobStream.pipeThrough(decompressionStream);
    return await new Response(decompressedStream).text();
}

function decompressUsingLib(arrayBuffer: ArrayBuffer): string | undefined {
    init();
    return decompressStringGzip(new Uint8Array(arrayBuffer));
}

export { decompressResponse }