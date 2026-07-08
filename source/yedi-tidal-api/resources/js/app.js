import SignaturePad from "signature_pad";
import "./bootstrap";

const referenceForm = document.querySelector("#reference-form");

if (referenceForm) {
    const canvas = document.querySelector("#signature-canvas");
    const signatureInput = document.querySelector("#signature-input");
    const clearSignatureBtn = document.querySelector("#clear-signature-btn");
    const wouldReemployInput = document.querySelector("#would_reemploy");
    const wouldReemployReasonInput = document.querySelector(
        "#would_reemploy_reason"
    );

    wouldReemployInput.addEventListener("change", function (e) {
        if (e.target.value === "0") {
            wouldReemployReasonInput.parentElement.classList.remove("hidden");
        } else {
            wouldReemployReasonInput.parentElement.classList.add("hidden");
            wouldReemployReasonInput.value = "";
        }
    });

    let windowWidth = window.innerWidth;

    const signaturePad = new SignaturePad(canvas, {});
    signaturePad.addEventListener("endStroke", function () {
        signatureInput.value = signaturePad.toDataURL();
        console.log(signatureInput.value);
        clearSignatureBtn.classList.remove("hidden");
    });

    clearSignatureBtn.addEventListener("click", function (e) {
        e.preventDefault();
        signaturePad.clear();
        signatureInput.value = "";
        clearSignatureBtn.classList.add("hidden");
    });

    window.addEventListener("resize", function () {
        const ratio = Math.max(window.devicePixelRatio || 1, 1);
        canvas.width = canvas.offsetWidth * ratio;
        canvas.height = canvas.offsetHeight * ratio;
        canvas.getContext("2d").scale(ratio, ratio);

        if (windowWidth !== window.innerWidth) {
            signaturePad.clear();
            signatureInput.value = "";
            windowWidth = window.innerWidth;
        }
    });
    window.dispatchEvent(new Event("resize"));

    if (signatureInput.value) {
        signaturePad.fromDataURL(signatureInput.value);
        clearSignatureBtn.classList.remove("hidden");
    }
}
