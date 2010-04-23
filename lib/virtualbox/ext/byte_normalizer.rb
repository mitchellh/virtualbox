module VirtualBox::ByteNormalizer
  # So that this is only defined once (suppress warnings)
  if !defined?(THOUSAND)
    THOUSAND = 1024.0
    BYTE = 1.0
    KILOBYTE = BYTE * THOUSAND
    MEGABYTE = KILOBYTE * THOUSAND
  end

  def bytes_to_megabytes(b)
    b / MEGABYTE
  end

  def megabytes_to_bytes(mb)
    mb * MEGABYTE
  end
end