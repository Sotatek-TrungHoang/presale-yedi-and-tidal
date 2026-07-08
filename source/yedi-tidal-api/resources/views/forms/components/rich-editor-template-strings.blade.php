@include('filament-forms::components.rich-editor')

@push('scripts')
  <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/tributejs/3.3.2/tribute.min.css" />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/tributejs/3.3.2/tribute.min.js"></script>

  <script>
    // Wait for the page to load before executing our code
    window.addEventListener('load', () => {
      // Get the component id, using the $getId() function of our RichEditor
      const id = '{{ $getId() }}';

      // Create the Tribute instance
      const tribute = new Tribute({
        // The values are the users that can be mentioned, so we will get this list from the mentionsItems variable that we created before in our custom component
        values: @json($getTemplateItems(), JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES),

        // Here we will customize the way that the mention must be shown, so when the user will mention another a link will be injected into the RichEditor with a link to the mentioned user's profile
        selectTemplate: function(item) {
          console.log(item);
          if (typeof item === "undefined") return null;
          if (this.range.isContentEditable(this.current.element)) {
            return item.original.value;
          }
          return item.original.value;
        },
      });

      // Attach the tribute instance to the RichEditor using the id retrieved above
      tribute.attach(document.getElementById(id));

      // Get the editor instance to override "keypress" and "keydown" events by an empty function
      const editor = document.getElementById(id).editor;
      if (editor != null) {
        editor.composition.delegate.inputController.events.keypress = function() {};
        editor.composition.delegate.inputController.events.keydown = function() {};
      }
    });
  </script>
@endpush
