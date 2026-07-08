<x-dynamic-component :component="$getEntryWrapperView()"
  :entry="$entry">
  <div>
    @if ($getState())
      <video controls>
        <source src="{{ $getState()['url'] }}">
      </video>
      <div class="mt-2 text-center">{{ $getState()['text'] }}</div>
    @else
    @endif
  </div>
</x-dynamic-component>
