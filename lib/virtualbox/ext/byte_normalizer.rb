module VirtualBox::ByteNormalizer
  # So that this is only defined once (suppress warnings)
  if !defined?(THOUSAND)
    THOUSAND = 1024
    BYTE = 1
    KILOBYTE = BYTE * THOUSAND
    MEGABYTE = KILOBYTE * THOUSAND
  end

  def megabytes_to_bytes(mb)
    mb * MEGABYTE
  end
end