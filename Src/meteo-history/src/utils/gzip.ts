import { ungzip } from "pako";

async function decompressResponse(response: Response): Promise<string | undefined> {
    if (response.headers.get("content-type") !== "application/gzip")
        return await response.text();

    const arrayBuffer = await response.arrayBuffer();
    const compressedBytes = new Uint8Array(arrayBuffer);
    const decompressedText: string = ungzip(compressedBytes, { to: 'string' });
    return decompressedText;
}

export { decompressResponse }