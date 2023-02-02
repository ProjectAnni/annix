pub fn add(left: usize, right: usize) -> usize {
    left + right
}

pub fn get_color_from_image(path: String) -> Vec<u32> {
    use image::io::Reader as ImageReader;
    use material_color_utilities_rs::quantize::quantizer_celebi::QuantizerCelebi;
    use material_color_utilities_rs::score::score;

    let image = ImageReader::open(path).unwrap().decode().unwrap();
    let resized_image = image.thumbnail(500, 500);
    drop(image);

    let image = resized_image.into_rgba8().into_vec();
    if image.len() % 4 != 0 {
        panic!("Invalid image buffer");
    }

    let mut offset = 0;
    let total = image.len();
    let mut pixels = Vec::with_capacity(total / 4);
    // RGBA -> ARGB
    while offset < total {
        pixels.push([
            image[offset + 3],
            image[offset],
            image[offset + 1],
            image[offset + 2],
        ]);
        offset += 4;
    }

    let mut quantizer = QuantizerCelebi;
    let result = quantizer.quantize(&pixels, 128);

    let result = score(&result);
    result
        .into_iter()
        .map(|[a, r, g, b]| ((a as u32) << 24) | ((r as u32) << 16) | ((g as u32) << 8) | b as u32)
        .collect()
}

#[cfg(test)]
mod tests {
    use super::get_color_from_image;

    #[test]
    fn test_image_color() {
        let color = get_color_from_image("/home/yesterday17/cover.jpg".to_string());
        panic!("{:#?}", color);
    }
}
