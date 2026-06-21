(function () {
    var PDFJS_VERSION = '3.11.174';
    if (window.pdfjsLib) {
        window.pdfjsLib.GlobalWorkerOptions.workerSrc =
            'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/' + PDFJS_VERSION + '/pdf.worker.min.js';
    }

    function annotationKey(annotation) {
        return annotation.page + ':' + annotation.id;
    }

    function createReview(modal) {
        var host = modal.querySelector('[data-pdf-review]');
        if (!host || host.dataset.ready === 'true') return;
        host.dataset.ready = 'true';

        var pdfUrl = host.getAttribute('data-pdf-url');
        var submissionId = Number(modal.getAttribute('data-submission-id')) || 0;
        var annotations = [];
        var pages = {};
        var activeTool = 'pointer';
        var nextId = 1;
        var drag = null;
        var originalBytes = null;
        var colorInput = modal.querySelector('[data-annotation-color]');
        var colorWrap = modal.querySelector('[data-annotation-color-wrap]');
        var saveDraftButton = modal.querySelector('[data-annotate-save-draft]');
        var saveDraftLabel = modal.querySelector('[data-save-draft-label]');
        var draftStatus = modal.querySelector('[data-annotation-draft-status]');
        var draftReady = false;
        var recentColorButtons = Array.prototype.slice.call(modal.querySelectorAll('[data-recent-colour]'));
        var highlightSizeButtons = Array.prototype.slice.call(modal.querySelectorAll('[data-highlight-size]'));
        var highlightSizeWrap = modal.querySelector('[data-highlight-size-wrap]');
        var highlightSize = 14;
        var undoStack = [];
        var redoStack = [];
        var colorTools = ['highlight', 'bookmark', 'text', 'strike', 'draw'];
        var toolColors = {
            highlight: '#facc15',
            bookmark: '#2563eb',
            text: '#b91c1c',
            strike: '#000000',
            draw: '#dc2626'
        };
        var recentColorsByTool = loadRecentColors();

        function loadRecentColors() {
            var defaults = {
                highlight: ['#facc15', '#ef4444', '#3b82f6'],
                bookmark: ['#2563eb', '#facc15', '#ef4444'],
                text: ['#b91c1c', '#2563eb', '#000000'],
                strike: ['#000000', '#ef4444', '#2563eb'],
                draw: ['#dc2626', '#2563eb', '#000000']
            };
            try {
                var saved = JSON.parse(window.localStorage.getItem('lecturerRecentAnnotationColorsByTool') || '{}');
                Object.keys(defaults).forEach(function (tool) {
                    var savedForTool = Array.isArray(saved[tool]) ? saved[tool] : [];
                    var valid = savedForTool.filter(function (color) {
                        return /^#[0-9a-f]{6}$/i.test(String(color));
                    });
                    saved[tool] = valid.concat(defaults[tool].filter(function (color) {
                        return valid.indexOf(color) === -1;
                    })).slice(0, 3);
                });
                return saved;
            } catch (error) {
                return defaults;
            }
        }

        function renderRecentColors() {
            var recentColors = recentColorsByTool[activeTool] || [];
            recentColorButtons.forEach(function (button, index) {
                var color = recentColors[index] || '#ffffff';
                button.style.backgroundColor = color;
                button.setAttribute('data-colour', color);
                button.title = 'Use ' + color;
            });
        }

        function rememberColor(color) {
            if (!/^#[0-9a-f]{6}$/i.test(String(color))) return;
            color = color.toLowerCase();
            var recentColors = recentColorsByTool[activeTool] || [];
            recentColorsByTool[activeTool] = [color].concat(recentColors.filter(function (existing) {
                return existing.toLowerCase() !== color;
            })).slice(0, 3);
            try {
                window.localStorage.setItem(
                    'lecturerRecentAnnotationColorsByTool',
                    JSON.stringify(recentColorsByTool)
                );
            } catch (error) {
                // Recent colours still work for the current page when storage is unavailable.
            }
            renderRecentColors();
        }

        function cloneAnnotations(source) {
            return JSON.parse(JSON.stringify(source));
        }

        function redrawAllPages() {
            Object.keys(pages).forEach(function (key) { redrawPage(Number(key)); });
        }

        function setDraftStatus(message, isError) {
            if (!draftStatus) return;
            draftStatus.textContent = message || '';
            draftStatus.classList.toggle('hidden', !message);
            draftStatus.classList.toggle('text-red-200', !!isError);
            draftStatus.classList.toggle('text-white/80', !isError);
        }

        function rememberChange() {
            undoStack.push(cloneAnnotations(annotations));
            redoStack = [];
            setDraftStatus('Unsaved changes', false);
        }

        function undo() {
            if (!undoStack.length) return;
            redoStack.push(cloneAnnotations(annotations));
            annotations = undoStack.pop();
            drag = null;
            redrawAllPages();
            setDraftStatus('Unsaved changes', false);
        }

        function redo() {
            if (!redoStack.length) return;
            undoStack.push(cloneAnnotations(annotations));
            annotations = redoStack.pop();
            drag = null;
            redrawAllPages();
            setDraftStatus('Unsaved changes', false);
        }

        modal.annotationHistory = {
            undo: undo,
            redo: redo
        };

        async function callPageMethod(method, payload) {
            var response = await fetch(window.location.pathname + '/' + method, {
                method: 'POST',
                credentials: 'same-origin',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify(payload)
            });
            if (!response.ok) throw new Error('The annotation server could not be reached.');
            var body = await response.json();
            return body && Object.prototype.hasOwnProperty.call(body, 'd') ? body.d : body;
        }

        async function loadAnnotationDraft() {
            if (!submissionId) return;
            var result = await callPageMethod('LoadAnnotationDraft', { submissionId: submissionId });
            if (!result || !result.success) {
                throw new Error(result && result.message ? result.message : 'Saved annotation progress could not be loaded.');
            }
            if (!result.annotationsJson) return;

            var restored = JSON.parse(result.annotationsJson);
            if (!Array.isArray(restored)) throw new Error('The saved annotation draft is invalid.');
            annotations = restored;
            nextId = annotations.reduce(function (highest, annotation) {
                return Math.max(highest, Number(annotation.id) || 0);
            }, 0) + 1;
            undoStack = [];
            redoStack = [];
            redrawAllPages();
            setDraftStatus('Saved progress restored', false);
        }

        async function saveAnnotationDraft() {
            if (!submissionId || !saveDraftButton || !draftReady) return;
            saveDraftButton.disabled = true;
            saveDraftButton.classList.add('opacity-60');
            if (saveDraftLabel) saveDraftLabel.textContent = 'Saving...';
            setDraftStatus('', false);
            try {
                var result = await callPageMethod('SaveAnnotationDraft', {
                    submissionId: submissionId,
                    annotationsJson: JSON.stringify(annotations)
                });
                if (!result || !result.success) {
                    throw new Error(result && result.message ? result.message : 'Annotation progress could not be saved.');
                }
                setDraftStatus('Progress saved', false);
            } finally {
                saveDraftButton.disabled = false;
                saveDraftButton.classList.remove('opacity-60');
                if (saveDraftLabel) saveDraftLabel.textContent = 'Save progress';
            }
        }

        function annotationColor(tool) {
            return toolColors[tool] || '#dc2626';
        }

        function hexToRgb(hex) {
            var value = String(hex || '#dc2626').replace('#', '');
            if (value.length === 3) {
                value = value.split('').map(function (part) { return part + part; }).join('');
            }
            var number = parseInt(value, 16);
            if (isNaN(number)) return { r: 220, g: 38, b: 38 };
            return {
                r: (number >> 16) & 255,
                g: (number >> 8) & 255,
                b: number & 255
            };
        }

        function cssColor(hex, alpha) {
            var rgb = hexToRgb(hex);
            return 'rgba(' + rgb.r + ',' + rgb.g + ',' + rgb.b + ',' + alpha + ')';
        }

        function pdfColor(hex) {
            var rgb = hexToRgb(hex);
            return window.PDFLib.rgb(rgb.r / 255, rgb.g / 255, rgb.b / 255);
        }

        function chooseTool(tool) {
            activeTool = tool;
            modal.querySelectorAll('[data-annotate-tool]').forEach(function (button) {
                button.classList.toggle('bg-white/15', button.getAttribute('data-annotate-tool') === tool);
            });
            Object.keys(pages).forEach(function (key) {
                var overlay = pages[key].overlay;
                var active = tool !== 'pointer';
                overlay.classList.toggle('pointer-events-none', !active);
                overlay.classList.toggle('pointer-events-auto', active);
                overlay.style.cursor = tool === 'eraser'
                    ? 'url("data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2724%27 height=%2724%27 viewBox=%270 0 24 24%27%3E%3Ccircle cx=%2712%27 cy=%2712%27 r=%276%27 fill=%27white%27 stroke=%27%2364748b%27 stroke-width=%271.5%27/%3E%3C/svg%3E") 12 12, crosshair'
                    : (active ? 'crosshair' : 'default');
            });
            var supportsColor = colorTools.indexOf(tool) !== -1;
            if (colorWrap) {
                colorWrap.classList.toggle('hidden', !supportsColor);
                colorWrap.classList.toggle('inline-flex', supportsColor);
            }
            if (colorInput && supportsColor) colorInput.value = annotationColor(tool);
            if (supportsColor) renderRecentColors();
            if (highlightSizeWrap) {
                var highlightActive = tool === 'highlight';
                highlightSizeWrap.classList.toggle('hidden', !highlightActive);
                highlightSizeWrap.classList.toggle('inline-flex', highlightActive);
            }
        }

        function canvasPoint(event, canvas) {
            var rect = canvas.getBoundingClientRect();
            return {
                x: (event.clientX - rect.left) * canvas.width / rect.width,
                y: (event.clientY - rect.top) * canvas.height / rect.height
            };
        }

        function toPdfPoint(pageInfo, displayPoint) {
            return {
                x: displayPoint.x / pageInfo.scale,
                y: pageInfo.pdfHeight - (displayPoint.y / pageInfo.scale)
            };
        }

        function toDisplayPoint(pageInfo, pdfPoint) {
            return {
                x: pdfPoint.x * pageInfo.scale,
                y: (pageInfo.pdfHeight - pdfPoint.y) * pageInfo.scale
            };
        }

        function drawAnnotation(context, pageInfo, annotation) {
            var start = toDisplayPoint(pageInfo, annotation.start);
            context.save();
            if (annotation.type === 'text') {
                context.font = 'bold 16px Arial';
                context.fillStyle = annotation.color || '#b91c1c';
                context.fillText(annotation.text, start.x, start.y);
            } else if (annotation.type === 'bookmark') {
                context.fillStyle = annotation.color || '#2563eb';
                context.beginPath();
                context.arc(start.x, start.y, 8, 0, Math.PI * 2);
                context.fill();
                context.font = 'bold 16px Arial';
                context.fillStyle = annotation.color || '#2563eb';
                context.fillText(annotation.text, start.x + 13, start.y + 5);
            } else if (annotation.type === 'strike') {
                var end = toDisplayPoint(pageInfo, annotation.end);
                context.strokeStyle = annotation.color || '#000000';
                context.lineWidth = 3;
                context.beginPath();
                context.moveTo(start.x, start.y);
                context.lineTo(end.x, end.y);
                context.stroke();
            } else if (annotation.type === 'highlight') {
                if (annotation.end) {
                    var highlightEnd = toDisplayPoint(pageInfo, annotation.end);
                    context.strokeStyle = cssColor(annotation.color || '#facc15', 0.35);
                    context.lineWidth = (annotation.size || 14) * pageInfo.scale;
                    context.lineCap = 'round';
                    context.beginPath();
                    context.moveTo(start.x, start.y);
                    context.lineTo(highlightEnd.x, highlightEnd.y);
                    context.stroke();
                }
            } else if (annotation.type === 'draw') {
                var points = annotation.points || [];
                if (points.length > 1) {
                    context.strokeStyle = annotation.color || '#dc2626';
                    context.lineWidth = 3;
                    context.lineCap = 'round';
                    context.lineJoin = 'round';
                    context.beginPath();
                    var first = toDisplayPoint(pageInfo, points[0]);
                    context.moveTo(first.x, first.y);
                    for (var i = 1; i < points.length; i++) {
                        var next = toDisplayPoint(pageInfo, points[i]);
                        context.lineTo(next.x, next.y);
                    }
                    context.stroke();
                }
            }
            context.restore();
        }

        function redrawPage(pageNumber, previewEnd) {
            var pageInfo = pages[pageNumber];
            if (!pageInfo) return;
            var context = pageInfo.overlay.getContext('2d');
            context.clearRect(0, 0, pageInfo.overlay.width, pageInfo.overlay.height);
            annotations
                .filter(function (annotation) { return annotation.page === pageNumber; })
                .forEach(function (annotation) { drawAnnotation(context, pageInfo, annotation); });

            if (drag && drag.page === pageNumber) {
                if (drag.type === 'draw') {
                    drawAnnotation(context, pageInfo, {
                        type: drag.type,
                        start: drag.points[0],
                        points: drag.points,
                        color: drag.color,
                        size: drag.size
                    });
                } else if (previewEnd) {
                    drawAnnotation(context, pageInfo, {
                        type: drag.type,
                        start: drag.start,
                        end: toPdfPoint(pageInfo, previewEnd),
                        color: drag.color,
                        size: drag.size
                    });
                }
            }
        }

        function nearestAnnotation(pageNumber, point) {
            var pageInfo = pages[pageNumber];
            var candidates = annotations.filter(function (annotation) { return annotation.page === pageNumber; });
            var closest = null;
            var closestDistance = 30;

            function distanceToSegment(target, start, end) {
                var lineX = end.x - start.x;
                var lineY = end.y - start.y;
                var lengthSquared = lineX * lineX + lineY * lineY;
                if (lengthSquared === 0) {
                    return Math.hypot(target.x - start.x, target.y - start.y);
                }

                var ratio = ((target.x - start.x) * lineX + (target.y - start.y) * lineY) / lengthSquared;
                ratio = Math.max(0, Math.min(1, ratio));
                var nearestX = start.x + ratio * lineX;
                var nearestY = start.y + ratio * lineY;
                return Math.hypot(target.x - nearestX, target.y - nearestY);
            }

            function distanceToRectangle(target, start, end) {
                var left = Math.min(start.x, end.x);
                var right = Math.max(start.x, end.x);
                var top = Math.min(start.y, end.y);
                var bottom = Math.max(start.y, end.y);
                var dx = Math.max(left - target.x, 0, target.x - right);
                var dy = Math.max(top - target.y, 0, target.y - bottom);
                return Math.hypot(dx, dy);
            }

            candidates.forEach(function (annotation) {
                var display = toDisplayPoint(pageInfo, annotation.start);
                var dx = display.x - point.x;
                var dy = display.y - point.y;
                var distance = Math.sqrt(dx * dx + dy * dy);
                if (annotation.type === 'strike' && annotation.end) {
                    var end = toDisplayPoint(pageInfo, annotation.end);
                    distance = distanceToSegment(point, display, end);
                } else if (annotation.type === 'highlight' && annotation.end) {
                    var highlightEnd = toDisplayPoint(pageInfo, annotation.end);
                    distance = Math.max(
                        0,
                        distanceToSegment(point, display, highlightEnd) -
                        ((annotation.size || 14) * pageInfo.scale / 2)
                    );
                } else if (annotation.type === 'draw' && annotation.points) {
                    annotation.points.forEach(function (pdfPoint) {
                        var strokePoint = toDisplayPoint(pageInfo, pdfPoint);
                        var strokeDx = strokePoint.x - point.x;
                        var strokeDy = strokePoint.y - point.y;
                        distance = Math.min(distance, Math.sqrt(strokeDx * strokeDx + strokeDy * strokeDy));
                    });
                }
                if (distance < closestDistance) {
                    closest = annotation;
                    closestDistance = distance;
                }
            });
            return closest;
        }

        function onPointerDown(event) {
            var overlay = event.currentTarget;
            var pageNumber = Number(overlay.getAttribute('data-page-number'));
            var pageInfo = pages[pageNumber];
            var displayPoint = canvasPoint(event, overlay);

            if (activeTool === 'eraser') {
                var target = nearestAnnotation(pageNumber, displayPoint);
                if (target) {
                    rememberChange();
                    var key = annotationKey(target);
                    annotations = annotations.filter(function (annotation) {
                        return annotationKey(annotation) !== key;
                    });
                    redrawPage(pageNumber);
                }
                return;
            }

            var pdfPoint = toPdfPoint(pageInfo, displayPoint);
            if (activeTool === 'text' || activeTool === 'bookmark') {
                var value = window.prompt(activeTool === 'text' ? 'Enter annotation text:' : 'Enter bookmark comment:');
                if (!value) return;
                rememberChange();
                annotations.push({
                    id: nextId++,
                    page: pageNumber,
                    type: activeTool,
                    text: value,
                    start: pdfPoint,
                    color: annotationColor(activeTool)
                });
                redrawPage(pageNumber);
                return;
            }

            if (activeTool === 'strike') {
                drag = {
                    page: pageNumber,
                    type: activeTool,
                    start: pdfPoint,
                    color: annotationColor(activeTool)
                };
                overlay.setPointerCapture(event.pointerId);
                event.preventDefault();
            } else if (activeTool === 'highlight') {
                drag = {
                    page: pageNumber,
                    type: 'highlight',
                    start: pdfPoint,
                    color: annotationColor('highlight'),
                    size: highlightSize
                };
                overlay.setPointerCapture(event.pointerId);
                event.preventDefault();
            } else if (activeTool === 'draw') {
                drag = {
                    page: pageNumber,
                    type: 'draw',
                    points: [pdfPoint],
                    color: annotationColor('draw')
                };
                overlay.setPointerCapture(event.pointerId);
                event.preventDefault();
            }
        }

        function onPointerMove(event) {
            if (!drag) return;
            var overlay = event.currentTarget;
            if (drag.type === 'draw') {
                drag.points.push(toPdfPoint(pages[drag.page], canvasPoint(event, overlay)));
                redrawPage(drag.page);
                event.preventDefault();
                return;
            }
            redrawPage(drag.page, canvasPoint(event, overlay));
            event.preventDefault();
        }

        function onPointerUp(event) {
            if (!drag) return;
            var overlay = event.currentTarget;
            var pageNumber = drag.page;
            rememberChange();
            if (drag.type === 'draw') {
                drag.points.push(toPdfPoint(pages[pageNumber], canvasPoint(event, overlay)));
                annotations.push({
                    id: nextId++,
                    page: pageNumber,
                    type: drag.type,
                    start: drag.points[0],
                    points: drag.points,
                    color: drag.color,
                    size: drag.size
                });
            } else {
                var end = toPdfPoint(pages[pageNumber], canvasPoint(event, overlay));
                annotations.push({
                    id: nextId++,
                    page: pageNumber,
                    type: drag.type,
                    start: drag.start,
                    end: end,
                    color: drag.color,
                    size: drag.size
                });
            }
            drag = null;
            redrawPage(pageNumber);
            event.preventDefault();
        }

        async function renderPdf() {
            if (!window.pdfjsLib || !window.PDFLib) {
                throw new Error('PDF libraries could not be loaded.');
            }
            var response = await fetch(pdfUrl, { credentials: 'same-origin' });
            if (!response.ok) throw new Error('The submitted PDF could not be loaded.');
            originalBytes = await response.arrayBuffer();
            var pdf = await window.pdfjsLib.getDocument({ data: originalBytes.slice(0) }).promise;
            host.innerHTML = '';

            for (var pageNumber = 1; pageNumber <= pdf.numPages; pageNumber++) {
                var page = await pdf.getPage(pageNumber);
                var baseViewport = page.getViewport({ scale: 1 });
                var availableWidth = Math.max(500, host.clientWidth - 4);
                var scale = Math.min(1.5, availableWidth / baseViewport.width);
                var viewport = page.getViewport({ scale: scale });

                var wrapper = document.createElement('div');
                wrapper.className = 'relative mx-auto overflow-hidden rounded border border-slate-300 bg-white shadow-sm';
                wrapper.style.width = viewport.width + 'px';
                wrapper.style.height = viewport.height + 'px';

                var pdfCanvas = document.createElement('canvas');
                pdfCanvas.width = viewport.width;
                pdfCanvas.height = viewport.height;
                pdfCanvas.className = 'block';

                var overlay = document.createElement('canvas');
                overlay.width = viewport.width;
                overlay.height = viewport.height;
                overlay.className = 'pointer-events-none absolute inset-0';
                overlay.setAttribute('data-page-number', String(pageNumber));
                overlay.addEventListener('pointerdown', onPointerDown);
                overlay.addEventListener('pointermove', onPointerMove);
                overlay.addEventListener('pointerup', onPointerUp);
                overlay.addEventListener('pointercancel', onPointerUp);

                wrapper.appendChild(pdfCanvas);
                wrapper.appendChild(overlay);
                host.appendChild(wrapper);
                pages[pageNumber] = {
                    overlay: overlay,
                    scale: scale,
                    pdfWidth: baseViewport.width,
                    pdfHeight: baseViewport.height
                };

                await page.render({ canvasContext: pdfCanvas.getContext('2d'), viewport: viewport }).promise;
            }
            chooseTool(activeTool);
        }

        async function downloadAnnotatedPdf() {
            if (!originalBytes) return;
            var PDFLib = window.PDFLib;
            var documentCopy = await PDFLib.PDFDocument.load(originalBytes.slice(0));
            var font = await documentCopy.embedFont(PDFLib.StandardFonts.HelveticaBold);
            var pdfPages = documentCopy.getPages();

            annotations.forEach(function (annotation) {
                var page = pdfPages[annotation.page - 1];
                if (!page) return;

                if (annotation.type === 'text') {
                    page.drawText(annotation.text, {
                        x: annotation.start.x,
                        y: annotation.start.y - 4,
                        size: 12,
                        font: font,
                        color: pdfColor(annotation.color || '#b91c1c')
                    });
                } else if (annotation.type === 'bookmark') {
                    page.drawCircle({
                        x: annotation.start.x,
                        y: annotation.start.y,
                        size: 6,
                        color: pdfColor(annotation.color || '#2563eb')
                    });
                    page.drawText(annotation.text, {
                        x: annotation.start.x + 10,
                        y: annotation.start.y - 4,
                        size: 11,
                        font: font,
                        color: pdfColor(annotation.color || '#2563eb')
                    });
                } else if (annotation.type === 'strike') {
                    page.drawLine({
                        start: annotation.start,
                        end: annotation.end,
                        thickness: 2,
                        color: pdfColor(annotation.color || '#000000')
                    });
                } else if (annotation.type === 'highlight') {
                    if (annotation.end) {
                        page.drawLine({
                            start: annotation.start,
                            end: annotation.end,
                            thickness: annotation.size || 14,
                            color: pdfColor(annotation.color || '#facc15'),
                            opacity: 0.35
                        });
                    }
                } else if (annotation.type === 'draw') {
                    var points = annotation.points || [];
                    for (var i = 1; i < points.length; i++) {
                        page.drawLine({
                            start: points[i - 1],
                            end: points[i],
                            thickness: 2,
                            color: pdfColor(annotation.color || '#dc2626')
                        });
                    }
                }
            });

            var bytes = await documentCopy.save();
            var blob = new Blob([bytes], { type: 'application/pdf' });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'annotated-submission.pdf';
            link.click();
            setTimeout(function () { URL.revokeObjectURL(link.href); }, 1000);
        }

        modal.querySelectorAll('[data-annotate-tool]').forEach(function (button) {
            button.addEventListener('click', function () {
                chooseTool(button.getAttribute('data-annotate-tool') || 'pointer');
            });
        });

        if (colorInput) {
            colorInput.addEventListener('input', function () {
                if (colorTools.indexOf(activeTool) !== -1) {
                    toolColors[activeTool] = colorInput.value;
                }
            });
            colorInput.addEventListener('change', function () {
                if (colorTools.indexOf(activeTool) !== -1) {
                    toolColors[activeTool] = colorInput.value;
                    rememberColor(colorInput.value);
                }
            });
        }

        recentColorButtons.forEach(function (button) {
            button.addEventListener('click', function () {
                var color = button.getAttribute('data-colour');
                if (!color || colorTools.indexOf(activeTool) === -1) return;
                toolColors[activeTool] = color;
                if (colorInput) colorInput.value = color;
            });
        });
        renderRecentColors();

        highlightSizeButtons.forEach(function (button) {
            button.addEventListener('click', function () {
                highlightSize = Number(button.getAttribute('data-highlight-size')) || 14;
                highlightSizeButtons.forEach(function (sizeButton) {
                    var selected = sizeButton === button;
                    sizeButton.setAttribute('data-active', selected ? 'true' : 'false');
                    sizeButton.classList.toggle('bg-white/15', selected);
                    sizeButton.classList.toggle('hover:bg-white/20', selected);
                    sizeButton.classList.toggle('hover:bg-white/10', !selected);
                });
            });
        });

        var clear = modal.querySelector('[data-annotate-clear]');
        if (clear) clear.addEventListener('click', function () {
            if (!annotations.length) return;
            rememberChange();
            annotations = [];
            redrawAllPages();
        });

        if (saveDraftButton) {
            saveDraftButton.disabled = true;
            saveDraftButton.classList.add('opacity-60');
            saveDraftButton.addEventListener('click', function () {
                saveAnnotationDraft().catch(function (error) {
                    setDraftStatus(error.message || 'Annotation progress could not be saved.', true);
                });
            });
        }

        var download = modal.querySelector('[data-annotate-download]');
        if (download) download.addEventListener('click', function () {
            downloadAnnotatedPdf().catch(function (error) {
                window.alert(error.message || 'Annotated PDF could not be created.');
            });
        });

        renderPdf()
            .then(function () { return loadAnnotationDraft(); })
            .then(function () {
                draftReady = true;
                if (saveDraftButton) {
                    saveDraftButton.disabled = false;
                    saveDraftButton.classList.remove('opacity-60');
                }
            })
            .catch(function (error) {
                if (!Object.keys(pages).length) {
                    host.innerHTML =
                        '<div class="rounded border border-red-200 bg-red-50 px-6 py-10 text-center text-red-700">' +
                        (error.message || 'PDF preview failed.') + '</div>';
                } else {
                    setDraftStatus(error.message || 'Saved progress could not be restored.', true);
                    draftReady = true;
                    if (saveDraftButton) {
                        saveDraftButton.disabled = false;
                        saveDraftButton.classList.remove('opacity-60');
                    }
                }
            });
    }

    function openModal(id) {
        var modal = document.querySelector('[data-review-modal="' + id + '"]');
        if (!modal) return;
        modal.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
        createReview(modal);
        if (window.lucide) window.lucide.createIcons();
    }

    function closeModal(modal) {
        if (!modal) return;
        modal.classList.add('hidden');
        document.body.style.overflow = '';
    }

    var studentSearch = document.querySelector('[data-filter-target="[data-grade-row]"]');
    if (studentSearch) {
        studentSearch.addEventListener('input', function () {
            var query = studentSearch.value.trim().toLowerCase();
            document.querySelectorAll('[data-grade-row]').forEach(function (row) {
                var text = (row.getAttribute('data-filter-text') || row.textContent || '').toLowerCase();
                row.style.display = !query || text.indexOf(query) !== -1 ? '' : 'none';
            });
        });
    }

    document.addEventListener('click', function (event) {
        var saveFeedback = event.target.closest('[data-save-feedback]');
        if (saveFeedback) {
            var reviewModal = saveFeedback.closest('[data-review-modal]');
            var feedbackInput = reviewModal ? reviewModal.querySelector('textarea') : null;
            if (!feedbackInput || !feedbackInput.value.trim()) {
                event.preventDefault();
                if (feedbackInput) {
                    feedbackInput.setCustomValidity('Feedback is required before saving.');
                    feedbackInput.reportValidity();
                    feedbackInput.focus();
                    feedbackInput.addEventListener('input', function clearFeedbackError() {
                        feedbackInput.setCustomValidity('');
                        feedbackInput.removeEventListener('input', clearFeedbackError);
                    });
                }
                return;
            }
        }

        var opener = event.target.closest('[data-review-open]');
        if (opener) {
            event.preventDefault();
            openModal(opener.getAttribute('data-review-open'));
            return;
        }
        var closer = event.target.closest('[data-review-close]');
        if (closer) {
            event.preventDefault();
            closeModal(closer.closest('[data-review-modal]'));
            return;
        }
        if (event.target.matches('[data-review-modal]')) closeModal(event.target);
    });

    document.addEventListener('keydown', function (event) {
        var activeModal = document.querySelector('[data-review-modal]:not(.hidden)');
        if (event.key === 'Escape') {
            closeModal(activeModal);
            return;
        }
        if (!activeModal || !activeModal.annotationHistory || !(event.ctrlKey || event.metaKey)) return;

        var target = event.target;
        var acceptsText = target && (
            target.matches('input, textarea, select') ||
            target.isContentEditable
        );
        if (acceptsText) return;

        var key = event.key.toLowerCase();
        if (key === 'z' && !event.shiftKey) {
            event.preventDefault();
            activeModal.annotationHistory.undo();
        } else if (key === 'y' || (key === 'z' && event.shiftKey)) {
            event.preventDefault();
            activeModal.annotationHistory.redo();
        }
    });
})();
