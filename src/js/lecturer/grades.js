(function () {
    function openModal(id) {
        var modal = document.querySelector('[data-review-modal="' + id + '"]');
        if (!modal) return;
        modal.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
        if (window.lucide) window.lucide.createIcons();
    }

    function closeModal(modal) {
        if (!modal) return;
        modal.classList.add('hidden');
        document.body.style.overflow = '';
    }

    document.addEventListener('click', function (event) {
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

        var modal = event.target.matches('[data-review-modal]') ? event.target : null;
        if (modal) closeModal(modal);
    });

    document.addEventListener('keydown', function (event) {
        if (event.key !== 'Escape') return;
        closeModal(document.querySelector('[data-review-modal]:not(.hidden)'));
    });
})();
